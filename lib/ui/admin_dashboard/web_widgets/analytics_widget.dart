import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'activity_chart.dart';
import 'report_donut_chart.dart';
import '../../../data/providers/activity_providers.dart';
import '../../../data/models/activity_log_item.dart';
import '../../../data/models/report.dart';

class AnalyticsWidget extends ConsumerStatefulWidget {
  final List<Report> reports;
  const AnalyticsWidget({super.key, required this.reports});

  @override
  ConsumerState<AnalyticsWidget> createState() => _AnalyticsWidgetState();
}

class _AnalyticsWidgetState extends ConsumerState<AnalyticsWidget> {
  int _selectedTab = 0; // 0 for Activity, 1 for Status

  @override
  Widget build(BuildContext context) {
    final allActivitiesAsync = ref.watch(allActivitiesProvider);

    // Calculate report status from widget.reports
    final reportStatus = <String, int>{};
    for (var report in widget.reports) {
      final status = report.status;
      reportStatus[status] = (reportStatus[status] ?? 0) + 1;
    }

    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Analytics',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 16),
            // Tab Selector
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF5F7FA),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(4),
              child: Row(
                children: [
                  Expanded(
                    child: _buildTab('Activity', 0),
                  ),
                  Expanded(
                    child: _buildTab('Reports', 1),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Content
            SizedBox(
              height: 280,
              child: _selectedTab == 0
                  ? allActivitiesAsync.when(
                      data: (activities) {
                        // Group activities by day
                        final groupedData = _groupActivitiesByDay(activities);
                        return ActivityChart(activities: groupedData);
                      },
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (err, _) => Center(child: Text('Error: $err')),
                    )
                  : ReportDonutChart(reportStatus: reportStatus),
            ),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _groupActivitiesByDay(List<ActivityLogItem> activities) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final result = <Map<String, dynamic>>[];

    // Generate last 7 days (chronological: 6 days ago -> Today)
    for (int i = 6; i >= 0; i--) {
      final date = today.subtract(Duration(days: i));
      final dayName = _getDayName(date.weekday);

      // Count activities for this specific calendar date
      int count = 0;
      for (var activity in activities) {
        final aDate = activity.timestamp;
        if (aDate.year == date.year && 
            aDate.month == date.month && 
            aDate.day == date.day) {
          count++;
        }
      }

      result.add({
        'day': dayName,
        'count': count,
      });
    }

    return result;
  }

  String _getDayName(int weekday) {
    switch (weekday) {
      case DateTime.monday: return 'Mon';
      case DateTime.tuesday: return 'Tue';
      case DateTime.wednesday: return 'Wed';
      case DateTime.thursday: return 'Thu';
      case DateTime.friday: return 'Fri';
      case DateTime.saturday: return 'Sat';
      case DateTime.sunday: return 'Sun';
      default: return '';
    }
  }

  Widget _buildTab(String label, int index) {
    final isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTab = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: .05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? const Color(0xFF1F2937) : const Color(0xFF6B7280),
          ),
        ),
      ),
    );
  }
}