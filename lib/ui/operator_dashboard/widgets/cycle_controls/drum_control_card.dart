import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/ui/operator_dashboard/models/drum_rotation_settings.dart';
import 'package:flutter_application_1/ui/operator_dashboard/models/system_status.dart';
import 'package:flutter_application_1/ui/operator_dashboard/widgets/cycle_controls/empty_state.dart';
import 'package:flutter_application_1/ui/operator_dashboard/widgets/cycle_controls/info_item.dart';
import 'package:flutter_application_1/ui/operator_dashboard/widgets/cycle_controls/control_input_fields.dart';
import 'package:flutter_application_1/data/models/batch_model.dart';
import 'package:flutter_application_1/data/providers/cycle_providers.dart';
import 'package:flutter_application_1/data/providers/machine_providers.dart';
import 'package:flutter_application_1/data/models/cycle_recommendation.dart';

class ControlInputCard extends ConsumerStatefulWidget {
  final BatchModel? currentBatch;
  final String? machineId;

  const ControlInputCard({super.key, this.currentBatch, this.machineId});

  @override
  ConsumerState<ControlInputCard> createState() => _ControlInputCardState();
}

class _ControlInputCardState extends ConsumerState<ControlInputCard> {
  DrumRotationSettings settings = DrumRotationSettings();
  SystemStatus status = SystemStatus.idle;

  String _uptime = '00:00:00';
  int _completedCycles = 0;
  DateTime? _startTime;
  Timer? _timer;
  Timer? _cycleTimer;
  CycleRecommendation? _cycleDoc;

  @override
  void initState() {
    super.initState();
    _initializeFromBatch();
  }

  void _initializeFromBatch() {
    if (widget.currentBatch != null && widget.currentBatch!.isActive) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _loadExistingCycle();
        }
      });
    } else {
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
    });
  }

  @override
  void didUpdateWidget(ControlInputCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    final currentBatchId = widget.currentBatch?.id;
    final oldBatchId = oldWidget.currentBatch?.id;

    debugPrint(
      '🔄 DrumControlCard didUpdateWidget: old=$oldBatchId, new=$currentBatchId',
    );

    if (currentBatchId != oldBatchId) {
      debugPrint('✅ Batch ID changed - reinitializing');
      _initializeFromBatch();
    } else if (widget.currentBatch != null &&
        oldWidget.currentBatch?.isActive == true &&
        !widget.currentBatch!.isActive) {
      debugPrint('⚠️ Batch completed');
      _stopTimer();
      _cycleTimer?.cancel();

      if (_cycleDoc != null) {
        _completeCycleInFirebase();
      }

      setState(() {
        status = SystemStatus.stopped;
      });
    }
  }

Future<void> _loadExistingCycle() async {
  if (widget.currentBatch == null) {
    debugPrint('⚠️ No current batch to load');
    return;
  }

  if (widget.machineId == null) {
    debugPrint('⚠️ No machine ID provided');
    return;
  }

  debugPrint(
    '📥 Loading drum controller for batch: ${widget.currentBatch!.id}',
  );

  try {
    // Check if machine has drumActive = true in Firestore
    final machineRepository = ref.read(machineRepositoryProvider);
    final machine = await machineRepository.getMachineById(widget.machineId!);
    
    if (machine == null) {
      debugPrint('❌ Machine not found');
      return;
    }

    // If drumActive is false in Firestore, don't proceed
    if (!machine.drumActive) {
      debugPrint('⚠️ Drum is not active in Firestore (drumActive: false)');
      if (mounted) {
        setState(() {
          settings.reset();
          status = SystemStatus.idle;
          _uptime = '00:00:00';
          _completedCycles = 0;
          _startTime = null;
          _cycleDoc = null;
        });
      }
      return;
    }

    // Load the cycle document
    final cycleRepository = ref.read(cycleRepositoryProvider);
    final cycles = await cycleRepository.getDrumControllers(
      batchId: widget.currentBatch!.id,
    );
    final cycle = cycles.isEmpty ? null : cycles.first;

    debugPrint(
      '📊 Drum controller loaded: ${cycle != null ? "Found" : "Not found"}',
    );

    if (mounted && cycle != null) {
      setState(() {
        _cycleDoc = cycle;
        settings = DrumRotationSettings(
          cycles: cycle.cycles ?? 1,
          period: cycle.duration ?? '10 minutes',
        );
        _completedCycles = cycle.completedCycles ?? 0;

        if (cycle.status == 'running') {
          status = SystemStatus.running;
          _startTime = cycle.startedAt;
          if (_startTime != null) {
            _startTimer();
            _simulateCycles();
          }
        } else if (cycle.status == 'completed') {
          status = SystemStatus.stopped;
          if (cycle.totalRuntimeSeconds != null) {
            _uptime = _formatDuration(
              Duration(seconds: cycle.totalRuntimeSeconds!),
            );
          }
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
      });
    }
  } catch (e) {
    debugPrint('❌ Error loading drum controller cycle: $e');
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
        setState(() {
          _uptime = _formatDuration(elapsed);
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
    if (widget.currentBatch == null || !widget.currentBatch!.isActive) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot start: No active batch'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (widget.machineId == null) {
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

    try {
      final cycleRepository = ref.read(cycleRepositoryProvider);
      final machineRepository = ref.read(machineRepositoryProvider);

      await cycleRepository.startDrumController(
        batchId: widget.currentBatch!.id,
        machineId: widget.currentBatch!.machineId,
        userId: user.uid,
        cycles: settings.cycles,
        duration: settings.period,
      );

      await machineRepository.updateDrumActive(widget.machineId!, true);

      final cycles = await cycleRepository.getDrumControllers(
        batchId: widget.currentBatch!.id,
      );
      final cycle = cycles.isEmpty ? null : cycles.first;

      setState(() {
        _cycleDoc = cycle;
        status = SystemStatus.running;
        _startTime = DateTime.now();
        _completedCycles = 0;
        _startTimer();
      });

      _simulateCycles();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Drum controller started'),
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
    }
  }

  Future<void> _handleStop() async {
    if (widget.machineId == null) return;

    try {
      final machineRepository = ref.read(machineRepositoryProvider);

      await machineRepository.updateDrumActive(widget.machineId!, false);

      _stopTimer();
      _cycleTimer?.cancel();

      if (_cycleDoc != null && widget.currentBatch?.id != null) {
        await _completeCycleInFirebase();
      }

      setState(() {
        status = SystemStatus.stopped;
        _uptime = '00:00:00';
        _completedCycles = 0;
        _startTime = null;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Drum controller stopped'),
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
    }
  }

  void _simulateCycles() {
    final periodMinutes = _getPeriodMinutes(settings.period);

    _cycleTimer = Timer.periodic(Duration(minutes: periodMinutes), (timer) async {
      if (mounted && status == SystemStatus.running) {
        setState(() {
          _completedCycles++;
        });

        if (widget.currentBatch?.id != null && _startTime != null) {
          try {
            final cycleRepository = ref.read(cycleRepositoryProvider);
            await cycleRepository.updateDrumProgress(
              batchId: widget.currentBatch!.id,
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

          if (widget.currentBatch?.id != null) {
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
    if (widget.currentBatch?.id == null) return;

    try {
      final cycleRepository = ref.read(cycleRepositoryProvider);
      await cycleRepository.completeDrumController(
        batchId: widget.currentBatch!.id,
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
    final hasActiveBatch =
        widget.currentBatch != null && widget.currentBatch!.isActive;
    final batchCompleted =
        widget.currentBatch != null && !widget.currentBatch!.isActive;

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

              if (!hasActiveBatch && !batchCompleted)
                const EmptyState()
              else
                _buildActiveState(
                  batchCompleted,
                  cardWidth,
                  cardHeight,
                  labelFontSize,
                  bodyFontSize,
                ),
            ],
          );

          return Padding(
            padding: EdgeInsets.all(cardWidth * 0.06),
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
                value: widget.currentBatch!.machineId,
                fontSize: bodyFontSize,
              ),
            ),
            SizedBox(width: cardWidth * 0.03),
            Expanded(
              child: InfoItem(
                label: 'Batch Name',
                value: widget.currentBatch!.displayName,
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
            SizedBox(width: cardWidth * 0.03),
            Expanded(
              child: InfoItem(
                label: 'No. of Cycles',
                value: _completedCycles.toString(),
                fontSize: bodyFontSize,
              ),
            ),
          ],
        ),
        SizedBox(height: cardHeight * 0.04),

        Text(
          'Set Controller',
          style: TextStyle(
            fontSize: labelFontSize,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1a1a1a),
          ),
        ),
        SizedBox(height: cardHeight * 0.025),

        ControlInputFields(
          selectedCycle: settings.cycles.toString(),
          selectedPeriod: settings.period,
          isLocked: status == SystemStatus.running,
          onCycleChanged: (value) {
            if (value != null) {
              setState(() {
                settings = settings.copyWith(cycles: int.parse(value));
              });
            }
          },
          onPeriodChanged: (value) {
            if (value != null) {
              setState(() {
                settings = settings.copyWith(period: value);
              });
            }
          },
        ),
        SizedBox(height: cardHeight * 0.04),

        if (status == SystemStatus.idle || status == SystemStatus.stopped)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: batchCompleted ? null : _handleStart,
              icon: const Icon(Icons.play_arrow),
              label: const Text('Start'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF14B8A6),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
                disabledBackgroundColor: Colors.grey.shade300,
              ),
            ),
          )
        else if (status == SystemStatus.running)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _handleStop,
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
    );
  }
}