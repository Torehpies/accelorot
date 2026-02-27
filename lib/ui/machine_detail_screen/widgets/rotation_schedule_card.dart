import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../../../data/models/machine_model.dart';
import '../../../../data/providers/cycle_providers.dart';
import '../../../../data/providers/substrate_providers.dart';
import 'manual_controls_modal.dart';


class RotationScheduleCard extends ConsumerStatefulWidget {
  final MachineModel machine;

  const RotationScheduleCard({super.key, required this.machine});

  @override
  ConsumerState<RotationScheduleCard> createState() => _RotationScheduleCardState();
}

class _RotationScheduleCardState extends ConsumerState<RotationScheduleCard> {
  bool _isExpanded = false;
  Timer? _countdownTimer;
  Timer? _rotationTimer;
  int _rotationSecondsRemaining = 180; // 3 minutes
  bool _isRotating = false;
  DateTime _now = DateTime.now();

  final List<TimeOfDay> _schedule = [
    const TimeOfDay(hour: 10, minute: 0),
    const TimeOfDay(hour: 16, minute: 0),
  ];

  @override
  void initState() {
    super.initState();
    _startCountdownTimer();
    _checkRotationState();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _rotationTimer?.cancel();
    super.dispose();
  }

  void _startCountdownTimer() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _now = DateTime.now();
      });
    });
  }

  void _checkRotationState() {
    if (widget.machine.drumActive) {
      // If drum is active, we should show rotating state
      // Note: We don't know exactly when it started from machine model alone,
      // but if we started it from this widget, we'd have the timer.
      // If it's already rotating (e.g. page refresh), we might need to fetch the cycle.
      _loadActiveCycle();
    }
  }

  Future<void> _loadActiveCycle() async {
    final batchId = widget.machine.currentBatchId;
    if (batchId == null || batchId.isEmpty) return;

    try {
      final cycleRepo = ref.read(cycleRepositoryProvider);
      final cycles = await cycleRepo.getDrumControllers(batchId: batchId);
      final activeCycle = cycles.isNotEmpty ? cycles.first : null;

      if (activeCycle != null && activeCycle.status == 'running' && widget.machine.drumActive) {
        final startedAt = activeCycle.startedAt ?? DateTime.now();
        final elapsedSeconds = DateTime.now().difference(startedAt).inSeconds;
        
        if (elapsedSeconds < 180) {
          setState(() {
            _isRotating = true;
            _rotationSecondsRemaining = 180 - elapsedSeconds;
          });
          _startRotationTimer();
        } else {
          // It should have stopped
          _stopRotation();
        }
      }
    } catch (e) {
      debugPrint('Error loading active cycle: $e');
    }
  }

  void _startRotationTimer() {
    _rotationTimer?.cancel();
    _rotationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_rotationSecondsRemaining > 0) {
        setState(() {
          _rotationSecondsRemaining--;
        });
      } else {
        _stopRotation();
      }
    });
  }

  Future<void> _startRotation() async {
    final batchId = widget.machine.currentBatchId;
    if (batchId == null) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() {
      _isRotating = true;
      _rotationSecondsRemaining = 180;
    });

    try {
      await ref.read(cycleRepositoryProvider).startDrumController(
            batchId: batchId,
            machineId: widget.machine.machineId,
            userId: user.uid,
            cycles: 1,
            duration: '3 minutes',
          );
      _startRotationTimer();
    } catch (e) {
      setState(() {
        _isRotating = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to start rotation: $e')),
        );
      }
    }
  }

  Future<void> _stopRotation() async {
    _rotationTimer?.cancel();
    final batchId = widget.machine.currentBatchId;
    if (batchId == null) return;

    try {
      await ref.read(cycleRepositoryProvider).stopDrumController(
            batchId: batchId,
            totalRuntimeSeconds: 180 - _rotationSecondsRemaining,
            expectedStatus: 'running',
          );
    } catch (e) {
      debugPrint('Error stopping rotation: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isRotating = false;
          _rotationSecondsRemaining = 180;
        });
      }
    }
  }

  DateTime _getNextRotationTime() {
    for (final time in _schedule) {
      final scheduledDateTime = DateTime(
        _now.year,
        _now.month,
        _now.day,
        time.hour,
        time.minute,
      );
      if (scheduledDateTime.isAfter(_now)) {
        return scheduledDateTime;
      }
    }
    // If no more today, get first one tomorrow
    final tomorrow = _now.add(const Duration(days: 1));
    return DateTime(
      tomorrow.year,
      tomorrow.month,
      tomorrow.day,
      _schedule.first.hour,
      _schedule.first.minute,
    );
  }

  String _formatCountdown(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    final batchId = widget.machine.currentBatchId ?? '';
    final substratesAsync = ref.watch(batchSubstratesProvider(batchId));
    final hasWaste = substratesAsync.value?.isNotEmpty ?? false;

    if (batchId.isEmpty || !hasWaste) {
      return _buildInactiveCard();
    }

    final nextRotation = _getNextRotationTime();
    final timeUntil = nextRotation.difference(_now);
    final isNear = timeUntil.inMinutes <= 15;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: _isRotating ? Colors.green : (isNear ? Colors.orange : Colors.transparent),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'NEXT ROTATION',
                      style: TextStyle(
                        color: Color(0xFF789CA4),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    Text(
                      '${_getCompletedToday()}/${_schedule.length}',
                      style: const TextStyle(
                        color: Color(0xFF789CA4),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F7F9),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.recycling, color: Color(0xFF22C55E), size: 32),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_isRotating) ...[
                            Text(
                              _formatRotationTimer(),
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                            const Text(
                              'Rotating...',
                              style: TextStyle(color: Colors.green, fontWeight: FontWeight.w500),
                            ),
                          ] else ...[
                            Text(
                              DateFormat('h:mm a').format(nextRotation),
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1F2937),
                              ),
                            ),
                            Text(
                              isNear ? 'Rotation due now' : 'in ${_formatCountdown(timeUntil)}',
                              style: TextStyle(
                                color: isNear ? Colors.orange : const Color(0xFF789CA4),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const Text(
                      'TODAY',
                      style: TextStyle(
                        color: Color(0xFF789CA4),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                if (_isRotating) ...[
                  const SizedBox(height: 16),
                  LinearProgressIndicator(
                    value: (180 - _rotationSecondsRemaining) / 180,
                    backgroundColor: Colors.green.withOpacity(0.1),
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ],
                if (isNear && !_isRotating) ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _startRotation,
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Start Rotation Now'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                InkWell(
                  onTap: () => setState(() => _isExpanded = !_isExpanded),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _isExpanded ? 'Hide Schedule & Controls' : 'Show Schedule & Controls',
                          style: const TextStyle(
                            color: Color(0xFF3B717B),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Icon(
                          _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                          color: const Color(0xFF3B717B),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_isExpanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "TODAY'S SCHEDULE",
                    style: TextStyle(
                      color: Color(0xFF789CA4),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ..._schedule.map((time) => _buildScheduleItem(time)),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 24),
                  _buildManualControlsEntry(context),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildManualControlsEntry(BuildContext context) {
    return InkWell(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => ManualControlsModal(machine: widget.machine),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF0F7F9)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.tune, color: Color(0xFF1F2937)),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Manual Controls',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFFD1D5DB)),
          ],
        ),
      ),
    );
  }

  Widget _buildInactiveCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'NEXT ROTATION',
                style: TextStyle(
                  color: Color(0xFF789CA4),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const Icon(Icons.info_outline, color: Color(0xFF789CA4), size: 16),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Row(
              children: [
                const Icon(Icons.hourglass_empty, color: Color(0xFF9CA3AF), size: 32),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Schedule Inactive',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF374151),
                        ),
                      ),
                      Text(
                        'Add waste to start rotation schedule.',
                        style: TextStyle(color: Color(0xFF6B7280), fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleItem(TimeOfDay time) {
    // ... (rest of the code remains the same)
    final scheduledDateTime = DateTime(_now.year, _now.month, _now.day, time.hour, time.minute);
    final isDone = scheduledDateTime.isBefore(_now) && !(_now.hour == time.hour && _now.minute - time.minute < 15);
    final isNext = scheduledDateTime == _getNextRotationTime();
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isDone ? Colors.green : (isNext ? const Color(0xFF1F2937) : const Color(0xFFF3F4F6)),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: isDone 
                ? const Icon(Icons.check, color: Colors.white, size: 20)
                : Text(
                    "${_schedule.indexOf(time) + 1}",
                    style: TextStyle(
                      color: isNext ? Colors.white : const Color(0xFF789CA4),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('h:mm a').format(scheduledDateTime),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
                Text(
                  isDone ? '5 min · logged by Berto' : (isNext ? '5 min · in ${_formatCountdown(scheduledDateTime.difference(_now))}' : '5 min'),
                  style: const TextStyle(color: Color(0xFF789CA4), fontSize: 13),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: isDone ? const Color(0xFFE6F4EA) : (isNext ? const Color(0xFFF3F4F6) : const Color(0xFFF9FAFB)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              isDone ? 'Done' : (isNext ? 'Next' : 'Pending'),
              style: TextStyle(
                color: isDone ? Colors.green : (isNext ? const Color(0xFF1F2937) : const Color(0xFF789CA4)),
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatRotationTimer() {
    final minutes = _rotationSecondsRemaining ~/ 60;
    final seconds = _rotationSecondsRemaining % 60;
    return "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')} / 03:00";
  }

  int _getCompletedToday() {
    int completed = 0;
    for (final time in _schedule) {
      if (DateTime(_now.year, _now.month, _now.day, time.hour, time.minute).isBefore(_now)) {
        completed++;
      }
    }
    return completed;
  }
}
