import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../data/models/cycle_recommendation.dart';
import '../../../../data/models/machine_model.dart';
import '../../../../data/providers/cycle_providers.dart';

// ---------------------------------------------------------------------------
// Filter enum
// ---------------------------------------------------------------------------
enum _RotationFilter { all, done, missed, manual }

// ---------------------------------------------------------------------------
// Rotation type enum & helpers
// ---------------------------------------------------------------------------
enum _RotationType { done, missed, manual }

extension _RotationTypeLabel on _RotationType {
  String get label {
    switch (this) {
      case _RotationType.done:
        return 'Done';
      case _RotationType.missed:
        return 'Missed';
      case _RotationType.manual:
        return 'Manual';
    }
  }

  Color get color {
    switch (this) {
      case _RotationType.done:
        return const Color(0xFF22C55E);
      case _RotationType.missed:
        return const Color(0xFFEF4444);
      case _RotationType.manual:
        return const Color(0xFF1F2937);
    }
  }

  Color get bgColor {
    switch (this) {
      case _RotationType.done:
        return const Color(0xFFDCFCE7);
      case _RotationType.missed:
        return const Color(0xFFFFE4E4);
      case _RotationType.manual:
        return const Color(0xFFF3F4F6);
    }
  }

  Widget buildIcon() {
    switch (this) {
      case _RotationType.done:
        return Container(
          width: 40, height: 40,
          decoration: const BoxDecoration(color: Color(0xFF22C55E), shape: BoxShape.circle),
          child: const Icon(Icons.check, color: Colors.white, size: 20),
        );
      case _RotationType.missed:
        return Container(
          width: 40, height: 40,
          decoration: const BoxDecoration(color: Color(0xFFEF4444), shape: BoxShape.circle),
          child: const Icon(Icons.close, color: Colors.white, size: 20),
        );
      case _RotationType.manual:
        return Container(
          width: 40, height: 40,
          decoration: const BoxDecoration(color: Color(0xFF1F2937), shape: BoxShape.circle),
          child: const Icon(Icons.person, color: Colors.white, size: 20),
        );
    }
  }
}

// ---------------------------------------------------------------------------
// Data model for a history entry (actual or computed-missed)
// ---------------------------------------------------------------------------
class _HistoryEntry {
  final _RotationType type;
  final DateTime time;
  final String title;
  final String? slotLabel;
  final String? operatorName;
  final int? runtimeSeconds;

  _HistoryEntry({
    required this.type,
    required this.time,
    required this.title,
    this.slotLabel,
    this.operatorName,
    this.runtimeSeconds,
  });
}

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------
final _batchDrumHistoryProvider =
    FutureProvider.autoDispose.family<List<CycleRecommendation>, String>(
  (ref, batchId) => ref.watch(cycleRepositoryProvider).getDrumControllers(batchId: batchId),
);

// ---------------------------------------------------------------------------
// Main screen
// ---------------------------------------------------------------------------
class RotationHistoryScreen extends ConsumerStatefulWidget {
  final MachineModel machine;

  const RotationHistoryScreen({super.key, required this.machine});

  @override
  ConsumerState<RotationHistoryScreen> createState() => _RotationHistoryScreenState();
}

class _RotationHistoryScreenState extends ConsumerState<RotationHistoryScreen> {
  _RotationFilter _filter = _RotationFilter.all;

  // Scheduled slot times (must match rotation_schedule_card.dart)
  static const List<TimeOfDay> _scheduledSlots = [
    TimeOfDay(hour: 8, minute: 0),
    TimeOfDay(hour: 16, minute: 0),
  ];

  // ---------------------------------------------------------------------------
  // Build a combined & sorted list of history entries from real cycles +
  // computed missed slots.
  // ---------------------------------------------------------------------------
  List<_HistoryEntry> _buildEntries(List<CycleRecommendation> cycles) {
    final entries = <_HistoryEntry>[];

    // Real cycle entries
    for (final cycle in cycles) {
      final time = cycle.startedAt ?? cycle.timestamp;
      if (time == null) continue;

      final isManual = cycle.duration == 'Manual';
      final type = isManual ? _RotationType.manual : _RotationType.done;
      final slot = _nearestSlotLabel(time);

      entries.add(_HistoryEntry(
        type: type,
        time: time,
        title: isManual ? 'Manual Run' : 'Scheduled Rotation Done',
        slotLabel: isManual ? null : slot,
        operatorName: cycle.operatorName,
        runtimeSeconds: cycle.totalRuntimeSeconds,
      ));
    }

    // Compute missed slots: for each day from the earliest cycle date up to yesterday,
    // if a scheduled slot has no matching rotation within ±15 min, mark it missed.
    final now = DateTime.now();
    DateTime earliest;
    if (cycles.isNotEmpty) {
      earliest = cycles
          .map((c) => c.startedAt ?? c.timestamp ?? now)
          .reduce((a, b) => a.isBefore(b) ? a : b);
    } else {
      earliest = now.subtract(const Duration(days: 7));
    }

    // Walk day by day from earliest to yesterday (don't count today's future slots as missed)
    for (
      var d = DateTime(earliest.year, earliest.month, earliest.day);
      d.isBefore(DateTime(now.year, now.month, now.day));
      d = d.add(const Duration(days: 1))
    ) {
      for (final slot in _scheduledSlots) {
        final slotDt = DateTime(d.year, d.month, d.day, slot.hour, slot.minute);
        // Check if any real cycle covers this slot (within ±15 min)
        final covered = cycles.any((c) {
          final t = c.startedAt ?? c.timestamp;
          if (t == null) return false;
          return (t.difference(slotDt).inMinutes.abs()) <= 15;
        });

        if (!covered) {
          entries.add(_HistoryEntry(
            type: _RotationType.missed,
            time: slotDt,
            title: 'Missed Scheduled Rotation',
            slotLabel: _slotLabel(slot),
            operatorName: null,
            runtimeSeconds: null,
          ));
        }
      }
    }

    // Also check today's already-passed slots
    for (final slot in _scheduledSlots) {
      final slotDt = DateTime(now.year, now.month, now.day, slot.hour, slot.minute);
      if (slotDt.isAfter(now)) continue; // future, skip
      final covered = cycles.any((c) {
        final t = c.startedAt ?? c.timestamp;
        if (t == null) return false;
        return (t.difference(slotDt).inMinutes.abs()) <= 15;
      });
      if (!covered) {
        entries.add(_HistoryEntry(
          type: _RotationType.missed,
          time: slotDt,
          title: 'Missed Scheduled Rotation',
          slotLabel: _slotLabel(slot),
          operatorName: null,
          runtimeSeconds: null,
        ));
      }
    }

    // Sort newest first
    entries.sort((a, b) => b.time.compareTo(a.time));
    return entries;
  }

  String _slotLabel(TimeOfDay slot) {
    final hour = slot.hour > 12 ? slot.hour - 12 : (slot.hour == 0 ? 12 : slot.hour);
    final ampm = slot.hour >= 12 ? 'PM' : 'AM';
    final min = slot.minute.toString().padLeft(2, '0');
    final slotNum = _scheduledSlots.indexOf(slot) + 1;
    return 'Slot $slotNum · $hour:$min $ampm';
  }

  String? _nearestSlotLabel(DateTime time) {
    int? bestSlotIdx;
    int bestDiff = 20; // max 15 min window
    for (int i = 0; i < _scheduledSlots.length; i++) {
      final slot = _scheduledSlots[i];
      final slotDt = DateTime(time.year, time.month, time.day, slot.hour, slot.minute);
      final diff = time.difference(slotDt).inMinutes.abs();
      if (diff <= 15 && diff < bestDiff) {
        bestDiff = diff;
        bestSlotIdx = i;
      }
    }
    if (bestSlotIdx == null) return null;
    return 'Slot ${bestSlotIdx + 1}';
  }

  // ---------------------------------------------------------------------------
  // Grouping helpers
  // ---------------------------------------------------------------------------
  Map<DateTime, List<_HistoryEntry>> _groupByDay(List<_HistoryEntry> entries) {
    final map = <DateTime, List<_HistoryEntry>>{};
    for (final e in entries) {
      final day = DateTime(e.time.year, e.time.month, e.time.day);
      map.putIfAbsent(day, () => []).add(e);
    }
    return map;
  }

  // ---------------------------------------------------------------------------
  // Filter apply
  // ---------------------------------------------------------------------------
  List<_HistoryEntry> _applyFilter(List<_HistoryEntry> entries) {
    switch (_filter) {
      case _RotationFilter.all:
        return entries;
      case _RotationFilter.done:
        return entries.where((e) => e.type == _RotationType.done).toList();
      case _RotationFilter.missed:
        return entries.where((e) => e.type == _RotationType.missed).toList();
      case _RotationFilter.manual:
        return entries.where((e) => e.type == _RotationType.manual).toList();
    }
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final batchId = widget.machine.currentBatchId ?? '';
    final historyAsync = ref.watch(_batchDrumHistoryProvider(batchId));
    final machineName = widget.machine.machineName;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F5F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF0F5F8),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Color(0xFF1F2937)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              machineName,
              style: const TextStyle(fontSize: 12, color: Color(0xFF789CA4), fontWeight: FontWeight.w500),
            ),
            const Text(
              'Rotation History',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
            ),
          ],
        ),
        titleSpacing: 0,
      ),
      body: historyAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF789CA4)),
          ),
        ),
        error: (e, _) => Center(
          child: Text('Failed to load history: $e', style: const TextStyle(color: Color(0xFF789CA4))),
        ),
        data: (cycles) {
          // Only drum_controller entries, already filtered by getDrumControllers
          final allEntries = _buildEntries(cycles);
          final filtered = _applyFilter(allEntries);
          final grouped = _groupByDay(filtered);
          final days = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

          return Column(
            children: [
              // Filter chips
              _buildFilterRow(),
              // List
              Expanded(
                child: filtered.isEmpty
                    ? _buildEmpty()
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                        itemCount: days.length,
                        itemBuilder: (context, idx) {
                          final day = days[idx];
                          final dayEntries = grouped[day]!;
                          return _buildDaySection(day, dayEntries);
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Filter row
  // ---------------------------------------------------------------------------
  Widget _buildFilterRow() {
    final filters = [
      (_RotationFilter.all, 'All'),
      (_RotationFilter.done, 'Done'),
      (_RotationFilter.missed, 'Missed'),
      (_RotationFilter.manual, 'Manual'),
    ];

    return Container(
      color: const Color(0xFFF0F5F8),
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: filters.map((pair) {
            final isSelected = _filter == pair.$1;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => setState(() => _filter = pair.$1),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF1F2937) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? const Color(0xFF1F2937) : const Color(0xFFE5E7EB),
                    ),
                  ),
                  child: Text(
                    pair.$2,
                    style: TextStyle(
                      color: isSelected ? Colors.white : const Color(0xFF6B7280),
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Day section
  // ---------------------------------------------------------------------------
  Widget _buildDaySection(DateTime day, List<_HistoryEntry> entries) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              DateFormat('MMM d, yyyy').format(day).toUpperCase(),
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                color: Color(0xFF789CA4),
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: List.generate(entries.length, (i) {
                return _buildEntry(entries[i], isLast: i == entries.length - 1);
              }),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Single entry row
  // ---------------------------------------------------------------------------
  Widget _buildEntry(_HistoryEntry entry, {required bool isLast}) {
    final timeStr = DateFormat('h:mm a').format(entry.time);
    final runtime = entry.runtimeSeconds;
    String? runtimeLabel;
    if (runtime != null && runtime > 0) {
      final mins = runtime ~/ 60;
      final secs = runtime % 60;
      runtimeLabel = mins > 0 ? '$mins min ${secs.toString().padLeft(2, '0')} sec' : '$secs sec';
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Timeline column
          SizedBox(
            width: 64,
            child: Column(
              children: [
                const SizedBox(height: 16),
                entry.type.buildIcon(),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: const Color(0xFFE5E7EB),
                    ),
                  ),
              ],
            ),
          ),
          // Content
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                top: 14,
                bottom: isLast ? 16 : 12,
                right: 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          entry.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        timeStr,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF9CA3AF),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      _buildTag(entry.type.label, entry.type.color, entry.type.bgColor),
                      if (entry.slotLabel != null)
                        _buildTag(entry.slotLabel!, const Color(0xFF6B7280), const Color(0xFFF3F4F6)),
                      if (entry.operatorName != null)
                        _buildIconTag(Icons.person_outline, entry.operatorName!, const Color(0xFF6B7280), const Color(0xFFF3F4F6)),
                      if (runtimeLabel != null)
                        _buildIconTag(Icons.timer_outlined, runtimeLabel, const Color(0xFF6B7280), const Color(0xFFF3F4F6)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String label, Color textColor, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(8)),
      child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: textColor)),
    );
  }

  Widget _buildIconTag(IconData icon, String label, Color color, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 3),
          Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: color)),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.history_rounded, size: 56, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          const Text(
            'No rotations found',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF9CA3AF)),
          ),
          const SizedBox(height: 4),
          const Text(
            'Rotation events will appear here',
            style: TextStyle(fontSize: 13, color: Color(0xFFD1D5DB)),
          ),
        ],
      ),
    );
  }
}
