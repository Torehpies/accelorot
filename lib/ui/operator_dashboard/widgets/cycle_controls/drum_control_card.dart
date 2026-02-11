 import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/ui/operator_dashboard/models/drum_rotation_settings.dart';
import 'package:flutter_application_1/ui/operator_dashboard/models/system_status.dart';
import 'package:flutter_application_1/ui/operator_dashboard/widgets/cycle_controls/empty_state.dart';
import 'package:flutter_application_1/ui/operator_dashboard/widgets/cycle_controls/info_item.dart';
import 'package:flutter_application_1/data/models/batch_model.dart';
import 'package:flutter_application_1/data/models/machine_model.dart';
import 'package:flutter_application_1/data/providers/cycle_providers.dart';
import 'package:flutter_application_1/data/providers/machine_providers.dart';
import 'package:flutter_application_1/data/providers/selected_machine_provider.dart';
import 'package:flutter_application_1/data/providers/selected_batch_provider.dart';
import 'package:flutter_application_1/data/providers/batch_providers.dart';
import 'package:flutter_application_1/data/models/cycle_recommendation.dart';
import 'package:flutter_application_1/ui/core/themes/app_theme.dart';

class ControlInputCard extends ConsumerStatefulWidget {
  final BatchModel? currentBatch;
  final String? machineId; // Deprecated - kept for backward compatibility

  const ControlInputCard({super.key, this.currentBatch, this.machineId});

  @override
  ConsumerState<ControlInputCard> createState() => _ControlInputCardState();
}

class _ControlInputCardState extends ConsumerState<ControlInputCard>
    with AutomaticKeepAliveClientMixin {
  DrumRotationSettings settings = DrumRotationSettings();
  SystemStatus status = SystemStatus.idle;

  String _uptime = '00:00:00';
  int _completedCycles = 0;
  DateTime? _startTime;
  Timer? _timer;
  Timer? _cycleTimer;
  CycleRecommendation? _cycleDoc;
  
  // Pause state tracking
  bool _isPaused = false;
  int _accumulatedSeconds = 0;
  
  // Track the current batch ID to detect actual changes
  String? _trackedBatchId;
  
  // Loading state
  bool _isLoading = false;
  
  // Track if we've already initialized to prevent re-initialization
  bool _isInitialized = false;
  
  @override
  bool get wantKeepAlive => true;
  
  // Helper getters to use providers instead of widget parameters
  String? get _machineId {
    final selectedMachineId = ref.read(selectedMachineIdProvider);
    return selectedMachineId.isEmpty ? null : selectedMachineId;
  }
  
  BatchModel? get _currentBatch {
    final selectedBatchId = ref.read(selectedBatchIdProvider);
    if (selectedBatchId == null) return null;
    
    final batchesAsync = ref.read(userTeamBatchesProvider);
    final batches = batchesAsync.asData?.value;
    if (batches == null) return null;
    
    try {
      return batches.firstWhere((batch) => batch.id == selectedBatchId);
    } catch (e) {
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    _trackedBatchId = _currentBatch?.id;
    _initializeFromBatch();
    
    // Listen to batch changes
    ref.listenManual(selectedBatchIdProvider, (previous, next) {
      if (next != _trackedBatchId) {
        debugPrint('🔄 Batch changed in provider: $_trackedBatchId -> $next');
        _trackedBatchId = next;
        _initializeFromBatch();
      }
    });
  }

  void _initializeFromBatch() {
    if (_currentBatch != null && _currentBatch!.isActive) {
      _trackedBatchId = _currentBatch!.id;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _loadExistingCycle();
        }
      });
    } else {
      _trackedBatchId = null;
      _resetState();
    }
  }

  void _resetState() {
    _stopTimer();
    _cycleTimer?.cancel();
    setState(() {
      settings.reset();
      status = SystemStatus.idle;
      _uptime = '00:00:00';
      _completedCycles = 0;
      _startTime = null;
      _cycleDoc = null;
      _isPaused = false;
      _accumulatedSeconds = 0;
      _isInitialized = false;
    });
  }

  /// Handle real-time machine state changes from Firebase stream
  void _handleMachineStateChange(bool drumActive) async {
    if (!mounted) return;
    
    // Get current machine state to check pause flag
    final machineRepository = ref.read(machineRepositoryProvider);
    final machine = await machineRepository.getMachineById(_machineId!);
    
    if (machine == null) return;
    
    final drumPaused = machine.drumPaused;
    
    debugPrint('🔔 Machine state changed: drumActive=$drumActive, drumPaused=$drumPaused, initialized=$_isInitialized');
    
    // Determine state based on drumActive and drumPaused combination
    if (drumActive && !drumPaused) {
      // Running state - only reload if not already initialized and running
      if (_isInitialized && status == SystemStatus.running && _startTime != null) {
        debugPrint('✅ Already running - skipping reload');
        return;
      }
      debugPrint('✅ Drum is RUNNING - reloading cycle state');
      await _loadExistingCycle();
    } else if (!drumActive && drumPaused) {
      // Paused state - need to load cycle to get accumulated time
      debugPrint('⏸️ Drum is PAUSED - loading paused state');
      
      // Load cycle to get accumulated runtime
      if (_currentBatch != null) {
        try {
          final cycleRepository = ref.read(cycleRepositoryProvider);
          final cycles = await cycleRepository.getDrumControllers(
            batchId: _currentBatch!.id,
          );
          final cycle = cycles.isEmpty ? null : cycles.first;
          
          if (cycle != null && cycle.accumulatedRuntimeSeconds != null) {
            _stopTimer();
            _cycleTimer?.cancel();
            setState(() {
              _cycleDoc = cycle;
              status = SystemStatus.idle;
              _isPaused = true;
              _accumulatedSeconds = cycle.accumulatedRuntimeSeconds!;
              _uptime = _formatDuration(Duration(seconds: cycle.accumulatedRuntimeSeconds!));
              _startTime = null;
            });
          }
        } catch (e) {
          debugPrint('❌ Error loading paused cycle: $e');
        }
      }
    } else if (!drumActive && !drumPaused) {
      // Stopped state
      debugPrint('⏹️ Drum is STOPPED - resetting to idle');
      _stopTimer();
      _cycleTimer?.cancel();
      setState(() {
        status = SystemStatus.idle;
        _isPaused = false;
      });
    }
  }

  Future<void> _loadExistingCycle() async {
  if (_currentBatch == null) {
    debugPrint('⚠️ No current batch to load');
    return;
  }

  if (_machineId == null) {
    debugPrint('⚠️ No machine ID provided');
    return;
  }

  // Set loading state
  if (mounted) {
    setState(() {
      _isLoading = true;
    });
  }

  debugPrint(
    '📥 Loading drum controller for batch: ${_currentBatch!.id}',
  );

  try {
    // Load the cycle document first
    final cycleRepository = ref.read(cycleRepositoryProvider);
    final cycles = await cycleRepository.getDrumControllers(
      batchId: _currentBatch!.id,
    );
    final cycle = cycles.isEmpty ? null : cycles.first;

    debugPrint('Drum controller loaded: ${cycle != null ? "Found" : "Not found"}');
    
    if (cycle != null) {
      debugPrint('Cycle status: ${cycle.status}');
    }

    // Check machine drumActive status
    final machineRepository = ref.read(machineRepositoryProvider);
    final machine = await machineRepository.getMachineById(_machineId!);
    
    if (machine == null) {
      debugPrint('❌ Machine not found');
      return;
    }

    // If no cycle exists and drumActive is false, reset to idle
    if (cycle == null && !machine.drumActive) {
      debugPrint('⚠️ No cycle and drum is not active - resetting to idle');
      if (mounted) {
        setState(() {
          settings.reset();
          status = SystemStatus.idle;
          _uptime = '00:00:00';
          _completedCycles = 0;
          _startTime = null;
          _cycleDoc = null;
          _isPaused = false;
          _accumulatedSeconds = 0;
        });
      }
      return;
    }

    // If cycle exists, restore state based on cycle status
    if (mounted && cycle != null) {
      bool isEffectivelyRunning = machine.drumActive;

      setState(() {
        _cycleDoc = cycle;
        settings = DrumRotationSettings(
          cycles: cycle.cycles ?? 1,
          period: cycle.duration ?? '10 minutes',
        );
        _completedCycles = cycle.completedCycles ?? 0;

        // Handle different statuses
        // Priority 1: Check actual machine state (Source of Truth)
        // If machine says running but cycle says stopped/completed, we are in a 'zombie' state.
        // We force the UI to running so the user can settle it (Stop).
        if (isEffectivelyRunning && 
           (cycle.status == 'stopped' || cycle.status == 'completed')) {
             debugPrint('⚠️ Zombie state detected: Machine running but cycle stopped. Forcing running state.');
             status = SystemStatus.running;
             _isPaused = false;
             // Use cycle start time or now if unavailable
             _startTime = cycle.startedAt ?? DateTime.now();
             _accumulatedSeconds = cycle.totalRuntimeSeconds ?? 0;
             
             if (_startTime != null) {
               _startTimer();
             }
             _isInitialized = true;

        } else if (cycle.status == 'paused') {
          debugPrint('Drum controller is paused');
          status = SystemStatus.idle;
          _isPaused = true;
          _accumulatedSeconds = cycle.accumulatedRuntimeSeconds ?? 0;
          _uptime = _formatDuration(Duration(seconds: _accumulatedSeconds));
          _startTime = null;
        } else if (cycle.status == 'running' && machine.drumActive) {
          debugPrint('Drum controller is running');
          status = SystemStatus.running;
          _isPaused = false;
          
          if (cycle.accumulatedRuntimeSeconds != null) {
            _accumulatedSeconds = cycle.accumulatedRuntimeSeconds!;
            _startTime = DateTime.now().subtract(Duration(seconds: _accumulatedSeconds));
          } else {
            _startTime = cycle.startedAt ?? DateTime.now();
            _accumulatedSeconds = 0;
          }
          
          if (_startTime != null) {
            _startTimer();
            _simulateCycles();
          }
          
          _isInitialized = true;
        } else if (cycle.status == 'stopped') {
          debugPrint('Drum controller was stopped - ready to restart');
          status = SystemStatus.idle;
          _isPaused = false;
          _uptime = '00:00:00';
          _completedCycles = 0;
          _startTime = null;
          _accumulatedSeconds = 0;
        } else if (cycle.status == 'completed') {
          debugPrint('Drum controller is completed');
          status = SystemStatus.stopped;
          _isPaused = false;
          if (cycle.totalRuntimeSeconds != null) {
            _uptime = _formatDuration(
              Duration(seconds: cycle.totalRuntimeSeconds!),
            );
          }
        } else {
          debugPrint('⚠️ Unknown drum controller state - resetting to idle');
          settings.reset();
          status = SystemStatus.idle;
          _isPaused = false;
          _uptime = '00:00:00';
          _completedCycles = 0;
          _startTime = null;
          _accumulatedSeconds = 0;
        }
      });
    } else if (mounted) {
       // No cycle document found
       // Check if machine is strangely running without a cycle doc
       if (machine.drumActive) {
         debugPrint('⚠️ Zombie state detected: Machine running but NO cycle doc found.');
         setState(() {
           status = SystemStatus.running;
           _isPaused = false;
           // We have to guess start time or just show 00:00:00
           _startTime = DateTime.now();
           _accumulatedSeconds = 0;
           _startTimer();
           _isInitialized = true;
         });
       } else {
         setState(() {
           settings.reset();
           status = SystemStatus.idle;
           _uptime = '00:00:00';
           _completedCycles = 0;
           _startTime = null;
           _cycleDoc = null;
           _isPaused = false;
           _accumulatedSeconds = 0;
         });
       }
    }
  } catch (e) {
    debugPrint('❌ Error loading drum controller cycle: $e');
  } finally {
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }
}

  /// Converts raw exception text into a clean, user-friendly snackbar message.
  String _getUserFriendlyError(Object e, String action) {
    final raw = e.toString();

    // Map known error patterns to friendly messages
    if (raw.contains('already running')) {
      return 'Machine is already running. Refreshing state...';
    }
    if (raw.contains('already stopped')) {
      return 'Machine is already stopped. Refreshing state...';
    }
    if (raw.contains('not running')) {
      return 'Machine was already stopped or paused. Refreshing...';
    }
    if (raw.contains('not paused')) {
      return 'Machine is no longer paused. Refreshing...';
    }
    if (raw.contains('Machine not found')) {
      return 'Machine not found. Please select a machine.';
    }
    if (raw.contains('No cycle document') || raw.contains('No drum controller') || raw.contains('No aerator')) {
      return 'No active cycle found. Please try again.';
    }
    // Catch the ugly Web-specific error and replace with a generic message
    if (raw.contains('Dart exception thrown from converted Future')) {
      return 'Operation failed. Another user may have changed the state. Refreshing...';
    }

    // Fallback: just show "Failed to [action]" without the raw exception
    return 'Failed to $action. Please try again.';
  }

  @override
  void dispose() {
    _stopTimer();
    _cycleTimer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted && _startTime != null) {
        final elapsed = DateTime.now().difference(_startTime!);
        final totalSeconds = _accumulatedSeconds + elapsed.inSeconds;
        
        setState(() {
          _uptime = _formatDuration(Duration(seconds: totalSeconds));
        });
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$hours:$minutes:$seconds';
  }

  Future<void> _handleStart() async {
    if (_isLoading) return;

    if (_currentBatch == null || !_currentBatch!.isActive) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot start: No active batch'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_machineId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No machine selected'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please log in to start the drum controller'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final cycleRepository = ref.read(cycleRepositoryProvider);

      debugPrint('🔵 Starting drum controller...');

      // Atomic start operation
      await cycleRepository.startDrumController(
        batchId: _currentBatch!.id,
        machineId: _currentBatch!.machineId,
        userId: user.uid,
        cycles: settings.cycles,
        duration: settings.period,
      );

      debugPrint('✅ Drum controller service started');

      // Wait a bit for Firestore stream to update UI naturally
      await Future.delayed(const Duration(milliseconds: 500));

      // We DON'T manually set state here anymore to avoid race conditions with stream
      // But for better UX, we can temporarily set it if mounted
      if (mounted) {
         // Optionally force a refresh or just let the stream handle it
         ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Drum controller started'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = _getUserFriendlyError(e, 'start');

        if (e.toString().contains('already running')) {
          _handleMachineStateChange(false);
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleStop() async {
    if (_isLoading) return;
    if (_machineId == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final cycleRepository = ref.read(cycleRepositoryProvider);

      // Atomic stop operation
      // Note: We calculate runtime here for the log, but backend handles machine state
      final elapsed = _startTime != null 
          ? DateTime.now().difference(_startTime!).inSeconds 
          : 0;
      final totalAccumulated = _accumulatedSeconds + elapsed;

      await cycleRepository.stopDrumController(
        batchId: _currentBatch!.id,
        totalRuntimeSeconds: totalAccumulated,
      );

      _stopTimer();
      _cycleTimer?.cancel();

      if (mounted) {
        setState(() {
          status = SystemStatus.idle;
          _uptime = '00:00:00';
          _completedCycles = 0;
          _startTime = null;
          _isPaused = false;
          _accumulatedSeconds = 0;
          _cycleDoc = null;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Drum controller stopped - controller reset'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = _getUserFriendlyError(e, 'stop');

        if (e.toString().contains('already stopped')) {
          _handleMachineStateChange(false);
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handlePause() async {
    if (_isLoading) return;
    if (_machineId == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final cycleRepository = ref.read(cycleRepositoryProvider);

      debugPrint('🔵 Starting pause operation...');

      final elapsed = _startTime != null 
          ? DateTime.now().difference(_startTime!).inSeconds 
          : 0;
      final totalAccumulated = _accumulatedSeconds + elapsed;
      
      // Atomic pause operation
      await cycleRepository.pauseDrumController(
        batchId: _currentBatch!.id,
        accumulatedRuntimeSeconds: totalAccumulated,
      );
      
      debugPrint('✅ Pause service call completed');

      _stopTimer();

      if (mounted) {
        setState(() {
          status = SystemStatus.idle;
          _isPaused = true;
          _accumulatedSeconds = totalAccumulated;
          _uptime = _formatDuration(Duration(seconds: totalAccumulated));
          _startTime = null;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Drum controller paused'),
            backgroundColor: Colors.blue,
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ Error in _handlePause: $e');
      if (mounted) {
        String errorMessage = _getUserFriendlyError(e, 'pause');

        if (e.toString().contains('not running') || e.toString().contains('already stopped')) {
          _handleMachineStateChange(false);
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleResume() async {
    if (_isLoading) return;
    if (_machineId == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final cycleRepository = ref.read(cycleRepositoryProvider);

      debugPrint('🔵 Starting resume operation...');

      // Atomic resume operation
      await cycleRepository.resumeDrumController(
        batchId: _currentBatch!.id,
      );
      
      debugPrint('✅ Resume service call completed');

      if (mounted) {
        setState(() {
          status = SystemStatus.running;
          _isPaused = false;
          _startTime = DateTime.now();
        });

        _startTimer();
        _simulateCycles(); // UI simulation only

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Drum controller resumed'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ Error in _handleResume: $e');
      if (mounted) {
        String errorMessage = _getUserFriendlyError(e, 'resume');

        if (e.toString().contains('not paused') || e.toString().contains('already stopped')) {
          _handleMachineStateChange(false);
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _simulateCycles() {
    final periodMinutes = _getPeriodMinutes(settings.period);

    _cycleTimer = Timer.periodic(Duration(minutes: periodMinutes), (timer) async {
      if (mounted && status == SystemStatus.running) {
        setState(() {
          _completedCycles++;
        });

        if (_currentBatch?.id != null && _startTime != null) {
          try {
            final cycleRepository = ref.read(cycleRepositoryProvider);
            await cycleRepository.updateDrumProgress(
              batchId: _currentBatch!.id,
              completedCycles: _completedCycles,
              totalRuntime: DateTime.now().difference(_startTime!),
            );
          } catch (e) {
            debugPrint('Failed to update drum progress: $e');
          }
        }

        if (_completedCycles >= settings.cycles) {
          _stopTimer();
          timer.cancel();

          if (_currentBatch?.id != null) {
            await _completeCycleInFirebase();
          }

          setState(() {
            status = SystemStatus.stopped;
          });
        }
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _completeCycleInFirebase() async {
    if (_currentBatch?.id == null) return;

    try {
      final cycleRepository = ref.read(cycleRepositoryProvider);
      await cycleRepository.completeDrumController(
        batchId: _currentBatch!.id,
      );
    } catch (e) {
      debugPrint('Failed to complete drum controller: $e');
    }
  }

  int _getPeriodMinutes(String period) {
    switch (period) {
      case '10 minutes':
        return 10;
      case '15 minutes':
        return 15;
      case '20 minutes':
        return 20;
      case '25 minutes':
        return 25;
      case '30 minutes':
        return 30;
      default:
        return 10;
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    
    // ✅ Use provider instead of widget parameter
    final selectedMachineId = ref.watch(selectedMachineIdProvider);
    final machineId = selectedMachineId.isEmpty ? null : selectedMachineId;
    
    // Listen for machine state changes (drumActive) to sync UI
    if (machineId != null) {
      ref.listen<AsyncValue<MachineModel?>>(
        machineStreamProvider(machineId),
        (previous, next) {
          next.whenData((machine) {
            if (machine != null) {
              _handleMachineStateChange(machine.drumActive);
            }
          });
        },
      );
    }
    
    final hasActiveBatch =
        _currentBatch != null && _currentBatch!.isActive;
    final batchCompleted =
        _currentBatch != null && !_currentBatch!.isActive;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.08),
            spreadRadius: 0,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final cardWidth = constraints.maxWidth;
          final cardHeight = constraints.maxHeight.isFinite ? constraints.maxHeight : 500.0;
          final baseFontSize = (cardWidth / 25).clamp(12.0, 20.0);
          final titleFontSize = baseFontSize;
          final labelFontSize = (baseFontSize * 0.8).clamp(10.0, 16.0);
          final bodyFontSize = (baseFontSize * 0.65).clamp(9.0, 13.0);
          final badgeFontSize = (baseFontSize * 0.6).clamp(9.0, 12.0);
          
          final useInternalScroll = constraints.maxHeight.isFinite;

          Widget content = Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      'Drum Controller',
                      style: TextStyle(
                        fontSize: titleFontSize,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1a1a1a),
                        letterSpacing: -0.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(width: cardWidth * 0.02),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: cardWidth * 0.03,
                      vertical: cardWidth * 0.015,
                    ),
                    decoration: BoxDecoration(
                      color: batchCompleted
                          ? const Color(0xFFF3F4F6)
                          : (hasActiveBatch
                                ? const Color(0xFFD1FAE5)
                                : const Color(0xFFFEF3C7)),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      batchCompleted
                          ? 'Completed'
                          : (hasActiveBatch ? 'Active' : 'Inactive'),
                      style: TextStyle(
                        fontSize: badgeFontSize,
                        fontWeight: FontWeight.w600,
                        color: batchCompleted
                            ? const Color(0xFF6B7280)
                            : (hasActiveBatch
                                  ? const Color(0xFF065F46)
                                  : const Color(0xFF92400E)),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: cardWidth * 0.06),

        
              hasActiveBatch || batchCompleted
                    ? _buildActiveState(
                        batchCompleted,
                        cardWidth,
                        cardHeight,
                        labelFontSize,
                        bodyFontSize,
                      )
                    : const EmptyState(),
            ],
          );

          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: useInternalScroll
                ? SingleChildScrollView(child: content)
                : content,
          );
        },
      ),
    );
  }

  Widget _buildActiveState(
    bool batchCompleted,
    double cardWidth,
    double cardHeight,
    double labelFontSize,
    double bodyFontSize,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: InfoItem(
                label: 'Machine Name',
                value: _currentBatch!.machineId,
                fontSize: bodyFontSize,
              ),
            ),
            SizedBox(width: cardWidth * 0.03),
            Expanded(
              child: InfoItem(
                label: 'Batch Name',
                value: _currentBatch!.displayName,
                fontSize: bodyFontSize,
              ),
            ),
          ],
        ),
        SizedBox(height: cardHeight * 0.03),

        Row(
          children: [
            Expanded(
              child: InfoItem(
                label: 'Uptime',
                value: _uptime,
                fontSize: bodyFontSize,
              ),
            ),
          ],
        ),
        SizedBox(height: cardHeight * 0.04),

        // Button logic
        if (_isPaused)
          // Paused: Show Resume and Stop
          Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _handleResume,
                  icon: _isLoading 
                      ? const SizedBox(
                          width: 20, 
                          height: 20, 
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)
                        )
                      : const Icon(Icons.play_arrow),
                  label: Text(_isLoading ? 'Processing...' : 'Resume'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF59E0B),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
              SizedBox(height: cardHeight * 0.02),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _handleStop,
                  icon: const Icon(Icons.stop),
                  label: const Text('Stop'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEF4444),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          )
        else if (status == SystemStatus.running)
          // Running: Show Pause and Stop
          Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _handlePause,
                  icon: _isLoading 
                      ? const SizedBox(
                          width: 20, 
                          height: 20, 
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)
                        )
                      : const Icon(Icons.pause),
                  label: Text(_isLoading ? 'Processing...' : 'Pause'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF59E0B),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
              SizedBox(height: cardHeight * 0.02),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _handleStop,
                  icon: const Icon(Icons.stop),
                  label: const Text('Stop'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEF4444),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          )
        else
          // Idle/Stopped: Show Start
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _handleStart,
              icon: _isLoading 
                  ? const SizedBox(
                      width: 20, 
                      height: 20, 
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)
                    )
                  : const Icon(Icons.play_arrow),
              label: Text(_isLoading ? 'Starting...' : 'Start'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.green100,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
            ),
          ),
      ],
    );
  }
}
