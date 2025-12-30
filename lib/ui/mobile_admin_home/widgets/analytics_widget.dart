import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'activity_chart.dart';
import 'status_chart.dart';
import '../../../data/providers/activity_providers.dart';
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
                    child: _buildTab('Status', 1),
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
                      data: (activities) => ActivityChart(activities: activities),
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (err, _) => Center(child: Text('Error: $err')),
                    )
                  : StatusChart(reports: widget.reports),
            ),
          ],
        ),
      ),
    );
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
                    color: Colors.black.withOpacity(0.05),
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