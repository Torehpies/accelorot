import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/ui/operator_dashboard/models/drum_rotation_settings.dart';
import 'package:flutter_application_1/ui/operator_dashboard/models/system_status.dart';
import 'package:flutter_application_1/ui/operator_dashboard/widgets/cycle_controls/empty_state.dart';
import 'package:flutter_application_1/ui/operator_dashboard/widgets/cycle_controls/info_item.dart';
import 'package:flutter_application_1/ui/operator_dashboard/widgets/cycle_controls/control_input_fields.dart';
import 'package:flutter_application_1/data/models/batch_model.dart';
import 'package:flutter_application_1/data/models/machine_model.dart';
import 'package:flutter_application_1/data/providers/cycle_providers.dart';
import 'package:flutter_application_1/data/providers/machine_providers.dart';
import 'package:flutter_application_1/data/providers/selected_machine_provider.dart';
import 'package:flutter_application_1/data/providers/selected_batch_provider.dart';
import 'package:flutter_application_1/data/providers/batch_providers.dart';
import 'package:flutter_application_1/data/models/cycle_recommendation.dart';
import 'package:flutter_application_1/ui/core/themes/app_theme.dart';

class AeratorCard extends ConsumerStatefulWidget {
  final BatchModel? currentBatch;
  final String? machineId; // Deprecated - kept for backward compatibility

  const AeratorCard({super.key, this.currentBatch, this.machineId});

  @override
  ConsumerState<AeratorCard> createState() => _AeratorCardState();
}

class _AeratorCardState extends ConsumerState<AeratorCard>
    with AutomaticKeepAliveClientMixin {
  DrumRotationSettings settings = DrumRotationSettings();
  SystemStatus status = SystemStatus.idle;
  
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
  
  // Track if we've already initialized to prevent re-initialization
  bool _isInitialized = false;

  // Loading state
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _trackedBatchId = _currentBatch?.id;
    if (_currentBatch != null && _currentBatch!.isActive) {
      _loadExistingCycle();
    }
    
    // Listen to batch changes
    ref.listenManual(selectedBatchIdProvider, (previous, next) {
      if (next != _trackedBatchId) {
        debugPrint('🔄 Aerator: Batch changed in provider: $_trackedBatchId -> $next');
        _trackedBatchId = next;
        _stopTimer();
        _cycleTimer?.cancel();
        
        if (_currentBatch != null && _currentBatch!.isActive) {
          _loadExistingCycle();
        } else {
          setState(() {
            settings.reset();
            status = SystemStatus.idle;
            _uptime = '00:00:00';
            _completedCycles = 0;
            _startTime = null;
            _cycleDoc = null;
            _isInitialized = false;
          });
        }
      }
    });
  }

  /// Handle real-time machine state changes from Firebase stream
  void _handleMachineStateChange(bool aeratorActive) async {
    if (!mounted) return;
    
    // Get current machine state to check pause flag
    final machineRepository = ref.read(machineRepositoryProvider);
    final machine = await machineRepository.getMachineById(_machineId!);
    
    if (machine == null) return;
    
    final aeratorPaused = machine.aeratorPaused;
    
    debugPrint('🔔 Machine state changed: aeratorActive=$aeratorActive, aeratorPaused=$aeratorPaused, initialized=$_isInitialized');
    
    // Determine state based on aeratorActive and aeratorPaused combination
    if (aeratorActive && !aeratorPaused) {
      // Running state - only reload if not already initialized and running
      if (_isInitialized && status == SystemStatus.running && _startTime != null) {
        debugPrint('✅ Already running - skipping reload');
        return;
      }
      debugPrint('✅ Aerator is RUNNING - reloading cycle state');
      await _loadExistingCycle();
    } else if (!aeratorActive && aeratorPaused) {
      // Paused state - need to load cycle to get accumulated time
      debugPrint('⏸️ Aerator is PAUSED - loading paused state');
      
      // Load cycle to get accumulated runtime
      if (_currentBatch != null) {
        try {
          final cycleRepository = ref.read(cycleRepositoryProvider);
          final cycles = await cycleRepository.getAerators(
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
    } else if (!aeratorActive && !aeratorPaused) {
      // Stopped state
      debugPrint('⏹️ Aerator is STOPPED - resetting to idle');
      _stopTimer();
      _cycleTimer?.cancel();
      setState(() {
        status = SystemStatus.idle;
        _isPaused = false;
      });
    }
  }

  Future<void> _loadExistingCycle() async {
  if (_currentBatch == null) return;

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

  try {
    // Load the cycle document first
    final cycleRepository = ref.read(cycleRepositoryProvider);
    final cycles = await cycleRepository.getAerators(
      batchId: _currentBatch!.id,
    );
    final cycle = cycles.isEmpty ? null : cycles.first;

    debugPrint('📊 Aerator loaded: ${cycle != null ? "Found" : "Not found"}');
    
    if (cycle != null) {
      debugPrint('📊 Cycle status: ${cycle.status}');
    }

    // Check machine aeratorActive status
    final machineRepository = ref.read(machineRepositoryProvider);
    final machine = await machineRepository.getMachineById(_machineId!);
    
    if (machine == null) {
      debugPrint('❌ Machine not found');
      return;
    }

    // If no cycle exists and aeratorActive is false, reset to idle
    if (cycle == null && !machine.aeratorActive) {
      debugPrint('⚠️ No cycle and aerator is not active - resetting to idle');
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
      setState(() {
        _cycleDoc = cycle;
        settings = DrumRotationSettings(
          cycles: cycle.cycles ?? 1,
          period: cycle.duration ?? '10 minutes',
        );
        _completedCycles = cycle.completedCycles ?? 0;

        // Handle different statuses
        if (cycle.status == 'paused') {
          debugPrint('📊 Aerator is paused');
          status = SystemStatus.idle;
          _isPaused = true;
          _accumulatedSeconds = cycle.accumulatedRuntimeSeconds ?? 0;
          _uptime = _formatDuration(Duration(seconds: _accumulatedSeconds));
          _startTime = null;
        } else if (cycle.status == 'running' && machine.aeratorActive) {
          debugPrint('📊 Aerator is running');
          status = SystemStatus.running;
          _isPaused = false;
          
          // Calculate the correct start time based on accumulated runtime
          // This ensures uptime continues correctly when reloading the cycle
          if (cycle.accumulatedRuntimeSeconds != null) {
            _accumulatedSeconds = cycle.accumulatedRuntimeSeconds!;
            // Set _startTime to a point in the past that accounts for accumulated time
            _startTime = DateTime.now().subtract(Duration(seconds: _accumulatedSeconds));
          } else {
            // Fallback: use the original startedAt time from the cycle
            _startTime = cycle.startedAt ?? DateTime.now();
            _accumulatedSeconds = 0;
          }
          
          if (_startTime != null) {
            _startTimer();
            _simulateCycles();
          }
          
          _isInitialized = true;
        } else if (cycle.status == 'stopped') {
          debugPrint('📊 Aerator was stopped - ready to restart');
          status = SystemStatus.idle;
          _isPaused = false;
          _uptime = '00:00:00';
          _completedCycles = 0;
          _startTime = null;
          _accumulatedSeconds = 0;
        } else if (cycle.status == 'completed') {
          debugPrint('📊 Aerator is completed');
          status = SystemStatus.stopped;
          _isPaused = false;
          if (cycle.totalRuntimeSeconds != null) {
            _uptime = _formatDuration(
              Duration(seconds: cycle.totalRuntimeSeconds!),
            );
          }
        } else {
          debugPrint('⚠️ Unknown aerator state - resetting to idle');
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
  } catch (e) {
    debugPrint('Error loading aerator cycle: $e');
  } finally {
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }
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
          content: Text('Please log in to start the aerator'),
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

      await cycleRepository.startAerator(
        batchId: _currentBatch!.id,
        machineId: _currentBatch!.machineId,
        userId: user.uid,
        cycles: settings.cycles,
        duration: settings.period,
      );

      // Set aeratorActive to true and aeratorPaused to false (running state)
      await FirebaseFirestore.instance
          .collection('machines')
          .doc(_machineId!)
          .update({
        'aeratorActive': true,
        'aeratorPaused': false,
        'lastModified': FieldValue.serverTimestamp(),
      });

      // Wait a bit for Firestore to propagate
      await Future.delayed(const Duration(milliseconds: 500));

      final cycles = await cycleRepository.getAerators(
        batchId: _currentBatch!.id,
      );
      final cycle = cycles.isEmpty ? null : cycles.first;

      // Only verify mounted here to prevent setState on disposed widget
      if (mounted) {
        setState(() {
          _cycleDoc = cycle;
          status = SystemStatus.running;
          _startTime = DateTime.now();
          _completedCycles = 0;
          _isPaused = false;
          _accumulatedSeconds = 0;
          _startTimer();
        });

        _simulateCycles();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Aerator started'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to start: $e'),
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

      // Set aeratorActive to false and aeratorPaused to false (stopped state)
      await FirebaseFirestore.instance
          .collection('machines')
          .doc(_machineId!)
          .update({
        'aeratorActive': false,
        'aeratorPaused': false,
        'lastModified': FieldValue.serverTimestamp(),
      });

      // Update cycle status to 'stopped' (NOT 'completed')
      if (_cycleDoc != null && _currentBatch?.id != null) {
        final elapsed = _startTime != null 
            ? DateTime.now().difference(_startTime!).inSeconds 
            : 0;
        final totalAccumulated = _accumulatedSeconds + elapsed;

        await cycleRepository.stopAerator(
          batchId: _currentBatch!.id,
          totalRuntimeSeconds: totalAccumulated,
        );
      }

      _stopTimer();
      _cycleTimer?.cancel();

      if (mounted) {
        setState(() {
          status = SystemStatus.idle;  // Back to idle (ready to start fresh)
          _uptime = '00:00:00';
          _completedCycles = 0;
          _startTime = null;
          _isPaused = false;
          _accumulatedSeconds = 0;
          _cycleDoc = null;  // Clear cycle doc reference
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Aerator stopped - controller reset'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to stop: $e'),
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
    if (_currentBatch == null || _machineId == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final cycleRepository = ref.read(cycleRepositoryProvider);

      // Calculate current runtime
      final elapsed = _startTime != null 
          ? DateTime.now().difference(_startTime!).inSeconds 
          : 0;
      final totalAccumulated = _accumulatedSeconds + elapsed;

      // Set aeratorActive to false and aeratorPaused to true (paused state)
      await FirebaseFirestore.instance
          .collection('machines')
          .doc(_machineId!)
          .update({
        'aeratorActive': false,
        'aeratorPaused': true,
        'lastModified': FieldValue.serverTimestamp(),
      });

      // Update cycle document to 'paused' status
      await cycleRepository.pauseAerator(
        batchId: _currentBatch!.id,
        accumulatedRuntimeSeconds: totalAccumulated,
      );

      // Stop local timers
      _stopTimer();
      _cycleTimer?.cancel();

      if (mounted) {
        setState(() {
          _isPaused = true;
          _accumulatedSeconds = totalAccumulated;
          _uptime = _formatDuration(Duration(seconds: totalAccumulated)); // Freeze uptime display
          status = SystemStatus.idle;  // Show as idle visually
          _startTime = null;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Aerator paused'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pause aerator: $e'),
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
    if (_currentBatch == null || _machineId == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final cycleRepository = ref.read(cycleRepositoryProvider);

      // Set aeratorActive to true and aeratorPaused to false (running state)
      await FirebaseFirestore.instance
          .collection('machines')
          .doc(_machineId!)
          .update({
        'aeratorActive': true,
        'aeratorPaused': false,
        'lastModified': FieldValue.serverTimestamp(),
      });

      // Update cycle document to 'running' status
      await cycleRepository.resumeAerator(
        batchId: _currentBatch!.id,
      );

      // Restart timer with accumulated time
      if (mounted) {
        setState(() {
          _isPaused = false;
          status = SystemStatus.running;
          _startTime = DateTime.now();  // New start time for this segment
        });

        _startTimer();
        _simulateCycles();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Aerator resumed'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to resume aerator: $e'),
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
            final elapsed = DateTime.now().difference(_startTime!).inSeconds;
            final totalRuntime = _accumulatedSeconds + elapsed;
            
            await cycleRepository.updateAeratorProgress(
              batchId: _currentBatch!.id,
              completedCycles: _completedCycles,
              totalRuntime: Duration(seconds: totalRuntime),
            );
          } catch (e) {
            debugPrint('Failed to update aerator progress: $e');
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
      await cycleRepository.completeAerator(batchId: _currentBatch!.id);
    } catch (e) {
      debugPrint('Failed to complete aerator: $e');
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
    
    // Listen for machine state changes (aeratorActive) to sync UI
    if (_machineId != null) {
      ref.listen<AsyncValue<MachineModel?>>(
        machineStreamProvider(_machineId!),
        (previous, next) {
          next.whenData((machine) {
            if (machine != null) {
              _handleMachineStateChange(machine.aeratorActive);
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
                      'Aerator',
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
            SizedBox(width: cardWidth * 0.04),
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
        if (status == SystemStatus.running && !_isPaused)
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
        else if (_isPaused)
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
        else
          // Idle/Stopped: Show Start
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: (_isLoading || batchCompleted) ? null : _handleStart,
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
                disabledBackgroundColor: Colors.grey.shade300,
              ),
            ),
          ),
      ],
    );
  }
}
