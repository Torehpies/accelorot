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
  static const int _rotationDurationSeconds = 120; // 2 minutes

  bool _isExpanded = false;
  Timer? _countdownTimer;
  Timer? _rotationTimer;
  int _rotationSecondsRemaining = _rotationDurationSeconds;
  bool _isRotating = false;
  DateTime _now = DateTime.now();
  // Tracks which schedule slots were already run this session (key = 'hour:minute')
  final Set<String> _completedSlots = <String>{};

  final List<TimeOfDay> _schedule = [
    const TimeOfDay(hour: 8, minute: 0),
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

  bool _isManualRotation = false;

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
        
        if (activeCycle.duration == 'Manual') {
          setState(() {
            _isRotating = true;
            _isManualRotation = true;
          });
          // Do not start rotation timer for auto-stop, as manual controls run infinitely
        } else {
          if (elapsedSeconds < _rotationDurationSeconds) {
            setState(() {
              _isRotating = true;
              _isManualRotation = false;
              _rotationSecondsRemaining = _rotationDurationSeconds - elapsedSeconds;
            });
            _startRotationTimer();
          } else {
            // It should have stopped
            _stopRotation();
          }
        }
      } else {
         setState(() {
           _isRotating = false;
           _isManualRotation = false;
         });
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

    // Mark the nearest near slot as completed so the notice won't re-appear
    for (final time in _schedule) {
      final scheduledDateTime = DateTime(_now.year, _now.month, _now.day, time.hour, time.minute);
      final timeUntil = scheduledDateTime.difference(_now);
      if (timeUntil.inMinutes <= 15 && timeUntil.inMinutes >= -5) {
        _completedSlots.add('${time.hour}:${time.minute}');
        break;
      }
    }

    setState(() {
      _isRotating = true;
      _rotationSecondsRemaining = _rotationDurationSeconds;
    });

    try {
      await ref.read(cycleRepositoryProvider).startDrumController(
            batchId: batchId,
            machineId: widget.machine.machineId,
            userId: user.uid,
            cycles: 1,
            duration: '2 minutes',
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
            totalRuntimeSeconds: _rotationDurationSeconds - _rotationSecondsRemaining,
            expectedStatus: 'running',
          );
    } catch (e) {
      debugPrint('Error stopping rotation: $e');
    } finally {
      setState(() {
        _isRotating = false;
        _rotationSecondsRemaining = _rotationDurationSeconds;
      });
    }
  }

  DateTime _getNextRotationTime() {
    for (final time in _schedule) {
      final key = '${time.hour}:${time.minute}';
      final scheduledDateTime = DateTime(
        _now.year,
        _now.month,
        _now.day,
        time.hour,
        time.minute,
      );
      // Skip if explicitly completed this session
      if (_completedSlots.contains(key)) continue;
      // Skip if already passed (missed) — only return future or "near" slots
      if (scheduledDateTime.isBefore(_now.subtract(const Duration(minutes: 15)))) continue;
      return scheduledDateTime;
    }
    // All done or passed today — return first slot tomorrow
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
    ref.listen(teamCyclesStreamProvider, (previous, next) {
      if (next.hasValue && next.value != null) {
        // Trigger a re-evaluation of the running state based on live cycle data
        _checkRotationState();
      }
    });

    final batchId = widget.machine.currentBatchId ?? '';
    final substratesAsync = ref.watch(batchSubstratesProvider(batchId));
    final hasWaste = substratesAsync.value?.isNotEmpty ?? false;

    final teamCyclesAsync = ref.watch(teamCyclesStreamProvider);

    if (teamCyclesAsync.isLoading || substratesAsync.isLoading) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFE5E7EB), width: 1.5),
        ),
        child: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF789CA4)),
          ),
        ),
      );
    }

    if (batchId.isEmpty || !hasWaste) {
      return _buildInactiveCard();
    }

    // Determine latest waste time
    DateTime? latestWasteTime;
    if (substratesAsync.value != null) {
      for (final substrate in substratesAsync.value!) {
        if (latestWasteTime == null || substrate.timestamp.isAfter(latestWasteTime)) {
          latestWasteTime = substrate.timestamp;
        }
      }
    }

    // Determine latest rotation time
    DateTime? latestRotationTime;
    if (teamCyclesAsync.value != null) {
      for (final cycle in teamCyclesAsync.value!) {
        if (cycle.batchId == batchId && cycle.controllerType == 'drum_controller') {
          final cycleTime = cycle.startedAt ?? cycle.timestamp;
          if (cycleTime != null && (latestRotationTime == null || cycleTime.isAfter(latestRotationTime))) {
            latestRotationTime = cycleTime;
          }
        }
      }
    }

    // Is rotation recommended?
    // Guard: don't show "Action Needed" while cycle data is still loading (prevents flash on open)
    final bool cyclesLoaded = !teamCyclesAsync.isLoading;
    final bool isRecommended = cyclesLoaded && latestWasteTime != null && (latestRotationTime == null || latestRotationTime.isBefore(latestWasteTime));

    final nextRotation = _getNextRotationTime();
    final timeUntil = nextRotation.difference(_now);
    final isNear = timeUntil.inMinutes <= 15;

    // Use isRecommended for UI logic specifically
    final bool showOrangeAlert = isRecommended || isNear;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: _isRotating ? (_isManualRotation ? const Color(0xFF6366f1) : Colors.green) : (showOrangeAlert ? Colors.orange : Colors.transparent),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _isRotating
                          ? 'ROTATING'
                          : isRecommended
                              ? 'ROTATION RECOMMENDED'
                              : isNear
                                  ? 'DUE SOON'
                                  : 'RESTING',
                      style: TextStyle(
                        color: _isRotating
                            ? (_isManualRotation ? const Color(0xFF6366f1) : Colors.green)
                            : showOrangeAlert
                                ? Colors.orange
                                : const Color(0xFF789CA4),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),

                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _isRotating
                            ? (_isManualRotation ? const Color(0xFF6366f1).withValues(alpha: 0.1) : Colors.green.withValues(alpha: 0.1))
                            : showOrangeAlert
                                ? Colors.orange.withValues(alpha: 0.1)
                                : const Color(0xFFF0F7F9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _isRotating
                            ? Icons.recycling
                            : isRecommended
                                ? Icons.warning_amber_rounded
                                : isNear
                                    ? Icons.notifications_active
                                    : Icons.bedtime_outlined,
                        color: _isRotating
                            ? (_isManualRotation ? const Color(0xFF6366f1) : Colors.green)
                            : showOrangeAlert
                                ? Colors.orange
                                : const Color(0xFF789CA4),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_isRotating) ...[  
                            if (_isManualRotation) ...[
                              Text(
                                DateFormat('h:mm a').format(_now),
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF6366f1),
                                ),
                              ),
                              const Text(
                                'Duration unknown',
                                style: TextStyle(color: Color(0xFF9ca3af), fontWeight: FontWeight.w500),
                              ),
                            ] else ...[
                              Text(
                                _formatRotationTimer(),
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                              const Text(
                                'Rotation in progress',
                                style: TextStyle(color: Colors.green, fontWeight: FontWeight.w500),
                              ),
                            ]
                          ] else if (isRecommended) ...[
                            const Text(
                              'Action Needed',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange,
                              ),
                            ),
                            const Text(
                              'Added waste needs mixing',
                              style: TextStyle(color: Colors.orange, fontWeight: FontWeight.w500),
                            ),
                          ] else if (isNear) ...[
                            Text(
                              _formatCountdown(timeUntil),
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange,
                              ),
                            ),
                            Text(
                              'Rotation at ${DateFormat('h:mm a').format(nextRotation)}',
                              style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.w500),
                            ),
                          ] else ...[
                            Text(
                              _formatCountdown(timeUntil),
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1F2937),
                              ),
                            ),
                            Text(
                              'until ${DateFormat('h:mm a').format(nextRotation)}',
                              style: const TextStyle(color: Color(0xFF789CA4), fontWeight: FontWeight.w500),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                if (_isRotating && _isManualRotation) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFe0e7ff),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info, color: Color(0xFF6366f1), size: 16),
                        const SizedBox(width: 8),
                        const Text(
                          'Started via manual controls',
                          style: TextStyle(
                            color: Color(0xFF4f46e5),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                if (_isRotating && !_isManualRotation) ...[
                  const SizedBox(height: 16),
                  LinearProgressIndicator(
                    value: (_rotationDurationSeconds - _rotationSecondsRemaining) / _rotationDurationSeconds,
                    backgroundColor: Colors.green.withValues(alpha: 0.1),
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ],
                if (showOrangeAlert && !_isRotating) ...[
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
                const SizedBox(height: 10),
                InkWell(
                  onTap: () => setState(() => _isExpanded = !_isExpanded),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 6),
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'NEXT SCHEDULE',
                    style: TextStyle(
                      color: Color(0xFF789CA4),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Build schedule: alternate rotation slots and rest slots
                  ..._buildFullScheduleList(),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),
                  _buildManualControlsEntry(context),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Builds a forward-looking schedule list always showing at least 2 upcoming items.
  /// Pattern: [current rest (if in rest)] → rotation → rest → rotation → rest ...
  List<Widget> _buildFullScheduleList() {
    final items = <Widget>[];
    final today = DateTime(_now.year, _now.month, _now.day);

    // We'll generate events by walking through cycles starting from now.
    // Each cycle = rotation slot + rest period after it.
    // We keep going until we've collected at least 2 upcoming events.

    int dayOffset = 0; // 0 = today, 1 = tomorrow, etc.
    int shown = 0;
    const maxItems = 4; // cap to avoid infinite build

    while (shown < 2 && dayOffset <= 7) {
      final base = today.add(Duration(days: dayOffset));
      final label = dayOffset == 0 ? '' : dayOffset == 1 ? ' (tomorrow)' : ' (+${dayOffset}d)';

      for (int i = 0; i < _schedule.length && shown < maxItems; i++) {
        final time = _schedule[i];
        final slotDt = DateTime(base.year, base.month, base.day, time.hour, time.minute);

        // Next rest end (after this rotation)
        final DateTime restEnd;
        if (i + 1 < _schedule.length) {
          final next = _schedule[i + 1];
          restEnd = DateTime(base.year, base.month, base.day, next.hour, next.minute);
        } else {
          final nextDay = base.add(const Duration(days: 1));
          final first = _schedule.first;
          restEnd = DateTime(nextDay.year, nextDay.month, nextDay.day, first.hour, first.minute);
        }

        // Are we currently in the rest BEFORE this slot? Show current rest first.
        if (shown == 0 && i == 0 && dayOffset == 0) {
          // Check if we're in overnight rest (before first slot today)
          final overnightRestStart = (() {
            final yesterday = today.subtract(const Duration(days: 1));
            final last = _schedule.last;
            return DateTime(yesterday.year, yesterday.month, yesterday.day, last.hour, last.minute);
          })();
          final firstSlotToday = DateTime(today.year, today.month, today.day, _schedule.first.hour, _schedule.first.minute);

          if (_now.isBefore(firstSlotToday) && _now.isAfter(overnightRestStart)) {
            // We are in overnight rest right now
            items.add(_buildRestSlot(
              'Resting until ${DateFormat('h:mm a').format(firstSlotToday)}',
              overnightRestStart,
              firstSlotToday,
              true,
            ));
            shown++;
          }
        }

        // Check if we are in the rest period AFTER this slot (and before next)
        if (dayOffset == 0 && slotDt.isBefore(_now) && restEnd.isAfter(_now)) {
          // Currently in rest after this rotation — show current rest item
          final inRestLabel = i + 1 < _schedule.length
              ? 'Resting until ${DateFormat('h:mm a').format(restEnd)}'
              : 'Resting until ${DateFormat('h:mm a').format(restEnd)} (tomorrow)';
          items.add(_buildRestSlot(inRestLabel, slotDt, restEnd, true));
          shown++;
          continue; // skip the rotation slot itself (already past)
        }

        // Skip past rotations
        if (slotDt.isBefore(_now)) continue;

        // Show upcoming rotation slot
        items.add(_buildScheduleItem(time, dayLabel: label));
        shown++;

        // Show rest after this rotation
        if (shown < maxItems) {
          final restLabel = i + 1 < _schedule.length
              ? 'Rest until ${DateFormat('h:mm a').format(restEnd)}'
              : 'Rest until ${DateFormat('h:mm a').format(restEnd)} (tomorrow)';
          items.add(_buildRestSlot(restLabel, slotDt, restEnd, false));
          shown++;
        }
      }

      dayOffset++;
    }

    return items;
  }

  Widget _buildRestSlot(String label, DateTime start, DateTime end, bool isActive) {
    final duration = end.difference(start);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final durationLabel = minutes == 0 ? '${hours}h rest' : '${hours}h ${minutes}m rest';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          // Thin rest line indicator instead of a numbered circle
          Column(
            children: [
              Container(width: 2, height: 12, color: const Color(0xFFE5E7EB)),
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: isActive ? const Color(0xFFEAF4FB) : const Color(0xFFF3F4F6),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFD1E1E9), width: 1.5),
                ),
              ),
              Container(width: 2, height: 12, color: const Color(0xFFE5E7EB)),
            ],
          ),
          const SizedBox(width: 26),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: isActive ? const Color(0xFF3B717B) : const Color(0xFF9CA3AF),
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: isActive ? const Color(0xFFEAF4FB) : const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              durationLabel,
              style: TextStyle(
                color: isActive ? const Color(0xFF3B717B) : const Color(0xFF9CA3AF),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildManualControlsEntry(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF8FBFD),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFC8DCE6), width: 1),
      ),
      child: InkWell(
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => ManualControlsModal(machine: widget.machine),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.tune_rounded,
                  color: Color(0xFF1F2937),
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Manual Controls',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1F2937),
                    letterSpacing: -0.2,
                  ),
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: Color(0xFF7C909C),
                size: 13,
              ),
            ],
          ),
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
            color: Colors.black.withValues(alpha: 0.05),
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

  Widget _buildScheduleItem(TimeOfDay time, {String dayLabel = ''}) {
    final key = '${time.hour}:${time.minute}';
    final scheduledDateTime = DateTime(_now.year, _now.month, _now.day, time.hour, time.minute);
    // Done only if we explicitly confirmed this rotation this session
    final isDone = _completedSlots.contains(key) && dayLabel.isEmpty;
    final isNext = !isDone && dayLabel.isEmpty && scheduledDateTime == _getNextRotationTime();
    
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
                  '${DateFormat('h:mm a').format(scheduledDateTime)}$dayLabel',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
                Text(
                  isDone
                      ? '2 min · done'
                      : isNext
                          ? '2 min · in ${_formatCountdown(scheduledDateTime.difference(_now))}'
                          : '2 min',
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
    return "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')} / 02:00";
  }

}
