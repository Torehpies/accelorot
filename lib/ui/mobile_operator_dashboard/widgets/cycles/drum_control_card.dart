import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/ui/mobile_operator_dashboard/widgets/view_model/cycles/drum_rotation_settings.dart';
import 'package:flutter_application_1/ui/mobile_operator_dashboard/widgets/view_model/cycles/system_status.dart';
import 'package:flutter_application_1/ui/home_screen/cycles/empty_state.dart';
import 'package:flutter_application_1/ui/home_screen/cycles/info_item.dart';
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
  String? _currentCycleId;
  CycleRecommendation? _cycleDoc;

  @override
  void initState() {
    super.initState();
    if (widget.currentBatch != null && widget.currentBatch!.isActive) {
      _loadExistingCycle();
    }
  }

  @override
  void didUpdateWidget(DrumControlCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (oldWidget.currentBatch?.id != widget.currentBatch?.id) {
      if (widget.currentBatch == null || !widget.currentBatch!.isActive) {
        _stopTimer();
        _cycleTimer?.cancel();
        setState(() {
          settings.reset();
          status = SystemStatus.idle;
          _uptime = '00:00:00';
          _completedCycles = 0;
          _startTime = null;
          _currentCycleId = null;
          _cycleDoc = null;
        });
      } else {
        _loadExistingCycle();
      }
    } else if (widget.currentBatch != null && 
               oldWidget.currentBatch?.isActive == true && 
               !widget.currentBatch!.isActive) {
      _stopTimer();
      _cycleTimer?.cancel();
      
      if (_currentCycleId != null && widget.currentBatch?.id != null) {
        _completeCycleInFirebase();
      }
      
      setState(() {
        status = SystemStatus.stopped;
      });
    }
  }

  Future<void> _loadExistingCycle() async {
    if (widget.currentBatch == null) return;

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final cycleRepository = ref.read(cycleRepositoryProvider);
      final cycle = await cycleRepository.getOrCreateCycleForBatch(
        batchId: widget.currentBatch!.id,
        machineId: widget.currentBatch!.machineId,
        userId: user.uid,
      );

      if (mounted && cycle.hasDrumController) {
        setState(() {
          _cycleDoc = cycle;
          _currentCycleId = cycle.id;
          settings = DrumRotationSettings(
            cycles: cycle.drumCycles ?? 50,
            period: cycle.drumDuration ?? '1 hour',
          );
          _completedCycles = cycle.drumCompletedCycles ?? 0;

          if (cycle.drumStatus == 'running') {
            status = SystemStatus.running;
            _startTime = cycle.drumStartedAt;
            if (_startTime != null) {
              _startTimer();
              _simulateCycles();
            }
          } else if (cycle.drumStatus == 'completed') {
            status = SystemStatus.stopped;
            if (cycle.drumTotalRuntimeSeconds != null) {
              _uptime = _formatDuration(
                Duration(seconds: cycle.drumTotalRuntimeSeconds!),
              );
            }
          }
        });
      }
    } catch (e) {
      debugPrint('Error loading drum controller cycle: $e');
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
      
      // Get or create cycle document
      if (_currentCycleId == null) {
        final cycle = await cycleRepository.getOrCreateCycleForBatch(
          batchId: widget.currentBatch!.id,
          machineId: widget.currentBatch!.machineId,
          userId: user.uid,
        );
        _currentCycleId = cycle.id;
      }

      // Start drum controller in Firebase
      await cycleRepository.startDrumController(
        batchId: widget.currentBatch!.id,
        cycleId: _currentCycleId!,
        cycles: settings.cycles,
        duration: settings.period,
      );

      setState(() {
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
    
    _cycleTimer = Timer.periodic(Duration(minutes: periodMinutes), (timer) async {
      if (mounted && status == SystemStatus.running) {
        setState(() {
          _completedCycles++;
        });

        // Update progress in Firebase
        if (_currentCycleId != null && widget.currentBatch?.id != null && _startTime != null) {
          try {
            final cycleRepository = ref.read(cycleRepositoryProvider);
            await cycleRepository.updateDrumProgress(
              batchId: widget.currentBatch!.id,
              cycleId: _currentCycleId!,
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
          
          // Complete cycle in Firebase
          if (_currentCycleId != null && widget.currentBatch?.id != null) {
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
    if (_currentCycleId == null || widget.currentBatch?.id == null) return;

    try {
      final cycleRepository = ref.read(cycleRepositoryProvider);
      await cycleRepository.completeDrumController(
        batchId: widget.currentBatch!.id,
        cycleId: _currentCycleId!,
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
    final hasActiveBatch = widget.currentBatch != null && widget.currentBatch!.isActive;
    final batchCompleted = widget.currentBatch != null && !widget.currentBatch!.isActive;

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
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Drum Controller',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1a1a1a),
                    letterSpacing: -0.5,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
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
                      fontSize: 12,
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
            const SizedBox(height: 24),

            if (!hasActiveBatch && !batchCompleted)
              const Expanded(child: EmptyState())
            else
              _buildActiveState(batchCompleted),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveState(bool batchCompleted) {
    final canInteract = !batchCompleted && status == SystemStatus.idle;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: InfoItem(
                label: 'Machine Name',
                value: widget.currentBatch!.machineId,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: InfoItem(
                label: 'Batch Name',
                value: widget.currentBatch!.displayName,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: InfoItem(
                label: 'Uptime',
                value: _uptime,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: InfoItem(
                label: 'No. of Cycles',
                value: _completedCycles.toString(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        const Text(
          'Set Controller',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1a1a1a),
          ),
        ),
        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: _buildDropdown(
                label: 'Select Duration',
                value: settings.period,
                items: ['15 minutes', '30 minutes', '1 hour', '2 hours'],
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
            const SizedBox(width: 12),
            Expanded(
              child: _buildDropdown(
                label: 'Select No. of Cycles',
                value: _getCyclesLabel(settings.cycles),
                items: ['50 Cycles', '100 Cycles', '150 Cycles', '200 Cycles'],
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
        const SizedBox(height: 24),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: canInteract ? _handleStart : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: batchCompleted
                  ? Colors.grey.shade400
                  : const Color(0xFF10B981),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
              disabledBackgroundColor: Colors.grey.shade300,
            ),
            child: Text(
              batchCompleted
                  ? 'Completed'
                  : (status == SystemStatus.idle ? 'Start' : status.displayName),
              style: const TextStyle(
                fontSize: 15,
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
    required Function(String?)? onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
              fontSize: 13,
              color: Colors.grey.shade600,
            ),
          ),
          isDense: true,
          isExpanded: true,
          icon: Icon(
            Icons.keyboard_arrow_down,
            color: Colors.grey.shade600,
            size: 20,
          ),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF1a1a1a),
                ),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}