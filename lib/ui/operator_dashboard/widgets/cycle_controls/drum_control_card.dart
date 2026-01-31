import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/ui/operator_dashboard/models/drum_rotation_settings.dart';
import 'package:flutter_application_1/ui/operator_dashboard/models/system_status.dart';
import 'package:flutter_application_1/ui/operator_dashboard/widgets/cycle_controls/empty_state.dart';
import 'package:flutter_application_1/ui/operator_dashboard/widgets/cycle_controls/info_item.dart';
import 'package:flutter_application_1/data/models/batch_model.dart';
import 'package:flutter_application_1/data/providers/cycle_providers.dart';
import 'package:flutter_application_1/data/models/cycle_recommendation.dart';

class DrumControlCard extends ConsumerStatefulWidget {
  final BatchModel? currentBatch;

  const DrumControlCard({super.key, this.currentBatch});

  @override
  ConsumerState<DrumControlCard> createState() => _DrumControlCardState();
}

class _DrumControlCardState extends ConsumerState<DrumControlCard> {
  DrumRotationSettings settings = DrumRotationSettings();
  SystemStatus status = SystemStatus.idle;

  String _uptime = '00:00:00';
  int _completedCycles = 0;
  DateTime? _startTime;
  Timer? _timer;
  Timer? _cycleTimer;
  CycleRecommendation? _cycleDoc;
  //String? _lastLoadedBatchId;

  @override
  void initState() {
    super.initState();
    _initializeFromBatch();
  }

  void _initializeFromBatch() {
    if (widget.currentBatch != null && widget.currentBatch!.isActive) {
      //_lastLoadedBatchId = widget.currentBatch!.id;
      // Schedule load after build completes
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
      //_lastLoadedBatchId = null;
    });
  }

  @override
  void didUpdateWidget(DrumControlCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    final currentBatchId = widget.currentBatch?.id;
    final oldBatchId = oldWidget.currentBatch?.id;

    debugPrint(
      '🔄 DrumControlCard didUpdateWidget: old=$oldBatchId, new=$currentBatchId',
    );

    // Batch changed
    if (currentBatchId != oldBatchId) {
      debugPrint('✅ Batch ID changed - reinitializing');
      _initializeFromBatch();
    }
    // Same batch became inactive
    else if (widget.currentBatch != null &&
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

    debugPrint(
      '📥 Loading drum controller for batch: ${widget.currentBatch!.id}',
    );

    try {
      final cycleRepository = ref.read(cycleRepositoryProvider);
      final cycle = await cycleRepository.getDrumController(
        batchId: widget.currentBatch!.id,
      );

      debugPrint(
        '📊 Drum controller loaded: ${cycle != null ? "Found" : "Not found"}',
      );

      if (mounted && cycle != null) {
        setState(() {
          _cycleDoc = cycle;
          settings = DrumRotationSettings(
            cycles: cycle.cycles ?? 50,
            period: cycle.duration ?? '1 hour',
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
        // No existing cycle - reset to idle state
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

  // ...rest of the existing methods remain the same...
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

      await cycleRepository.startDrumController(
        batchId: widget.currentBatch!.id,
        machineId: widget.currentBatch!.machineId,
        userId: user.uid,
        cycles: settings.cycles,
        duration: settings.period,
      );

      final cycle = await cycleRepository.getDrumController(
        batchId: widget.currentBatch!.id,
      );

      setState(() {
        _cycleDoc = cycle;
        status = SystemStatus.running;
        _startTime = DateTime.now();
        _completedCycles = 0;
        _startTimer();
      });

      _simulateCycles();
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

  void _simulateCycles() {
    final periodMinutes = _getPeriodMinutes(settings.period);

    _cycleTimer = Timer.periodic(Duration(minutes: periodMinutes), (
      timer,
    ) async {
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
      case '15 minutes':
        return 15;
      case '30 minutes':
        return 30;
      case '1 hour':
        return 60;
      case '2 hours':
        return 120;
      default:
        return 60;
    }
  }

  String _getCyclesLabel(int cycles) {
    return '$cycles Cycles';
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
          // Scale fonts based on card width (not screen width)
          final cardWidth = constraints.maxWidth;
          final cardHeight = constraints.maxHeight;
          final baseFontSize = (cardWidth / 25).clamp(12.0, 20.0); // Dynamic scaling
          final titleFontSize = baseFontSize;
          final labelFontSize = (baseFontSize * 0.8).clamp(10.0, 16.0);
          final bodyFontSize = (baseFontSize * 0.65).clamp(9.0, 13.0);
          final badgeFontSize = (baseFontSize * 0.6).clamp(9.0, 12.0);
          
          return Padding(
            padding: EdgeInsets.all(cardWidth * 0.06), // 6% of card width
            child: Column(
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
                  Flexible(
                    child: _buildActiveState(
                      batchCompleted,
                      cardWidth,
                      cardHeight,
                      labelFontSize,
                      bodyFontSize,
                    ),
                  ),
              ],
            ),
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
    final canInteract = !batchCompleted && status == SystemStatus.idle;

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

        Row(
          children: [
            Expanded(
              child: _buildDropdown(
                label: 'Select Duration',
                value: settings.period,
                items: ['15 minutes', '30 minutes', '1 hour', '2 hours'],
                screenWidth: cardWidth,
                onChanged: canInteract
                    ? (value) {
                        if (value != null) {
                          setState(() {
                            settings = settings.copyWith(period: value);
                          });
                        }
                      }
                    : null,
              ),
            ),
            SizedBox(width: cardWidth * 0.03),
            Expanded(
              child: _buildDropdown(
                label: 'Select No. of Cycles',
                value: _getCyclesLabel(settings.cycles),
                items: ['50 Cycles', '100 Cycles', '150 Cycles', '200 Cycles'],
                screenWidth: cardWidth,
                onChanged: canInteract
                    ? (value) {
                        if (value != null) {
                          final cycles = int.parse(value.split(' ')[0]);
                          setState(() {
                            settings = settings.copyWith(cycles: cycles);
                          });
                        }
                      }
                    : null,
              ),
            ),
          ],
        ),
        SizedBox(height: cardHeight * 0.04),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: canInteract ? _handleStart : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: batchCompleted
                  ? Colors.grey.shade400
                  : const Color(0xFF10B981),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: cardHeight * 0.025),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
              disabledBackgroundColor: Colors.grey.shade300,
            ),
            child: Text(
              batchCompleted
                  ? 'Completed'
                  : (status == SystemStatus.idle
                        ? 'Start'
                        : status.displayName),
              style: TextStyle(
                fontSize: labelFontSize,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required double screenWidth,
    required Function(String?)? onChanged,
  }) {
    // Calculate font size based on card width
    final dropdownFontSize = (screenWidth / 30).clamp(10.0, 13.0);
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.03,
        vertical: screenWidth * 0.025,
      ),
      decoration: BoxDecoration(
        color: onChanged == null ? Colors.grey.shade100 : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(
            label,
            style: TextStyle(
              fontSize: dropdownFontSize,
              color: Colors.grey.shade600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          isDense: true,
          isExpanded: true,
          icon: Icon(
            Icons.keyboard_arrow_down,
            color: Colors.grey.shade600,
            size: (screenWidth / 20).clamp(16.0, 20.0),
          ),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                style: TextStyle(
                  fontSize: dropdownFontSize,
                  color: const Color(0xFF1a1a1a),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
