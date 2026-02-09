// lib/ui/mobile_operator_dashboard/widgets/add_waste/activity_logs_mobile.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/models/activity_log_item.dart';
import '../../../../data/providers/activity_providers.dart';
import 'activity_log_item_widget.dart';

/// Mobile card-based activity logs view
class ActivityLogsMobile extends ConsumerWidget {
  const ActivityLogsMobile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ✅ Use streaming provider for real-time updates
    final activitiesAsync = ref.watch(allActivitiesStreamProvider);

    return activitiesAsync.when(
      data: (allLogs) => _buildContent(allLogs),
      loading: () => const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
        ),
      ),
      error: (error, stack) => _buildErrorState(),
    );
  }

  Widget _buildContent(List<ActivityLogItem> allLogs) {
    if (allLogs.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.inbox_outlined, size: 48, color: Colors.grey.shade300),
              const SizedBox(height: 12),
              const Text(
                'No logs yet. Add waste or submit a report to get started!',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      itemCount: allLogs.length,
      padding: EdgeInsets.zero,
      physics: const ClampingScrollPhysics(),
      itemBuilder: (context, index) {
        final log = allLogs[index];
        return ActivityLogItemWidget(log: log);
      },
      separatorBuilder: (context, index) => const SizedBox(height: 0),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            const Text(
              'Failed to load activities',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
