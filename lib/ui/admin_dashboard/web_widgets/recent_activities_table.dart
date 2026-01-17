// lib/ui/web_admin_home/widgets/recent_activities_table.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/providers/activity_providers.dart';
import '../../../data/providers/batch_providers.dart';
import '../../../data/models/activity_log_item.dart';

class RecentActivitiesTable extends ConsumerWidget {
  const RecentActivitiesTable({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activitiesAsync = ref.watch(allActivitiesProvider);
    final batchesAsync = ref.watch(userTeamBatchesProvider);
    final batches = batchesAsync.value ?? [];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Recent Activities', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF374151))),
              IconButton(
                icon: const Icon(Icons.refresh, size: 16),
                onPressed: () => ref.invalidate(allActivitiesProvider),
                tooltip: 'Refresh',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildHeader(),
          const Divider(height: 1, color: Color(0xFFE5E7EB)),
          const SizedBox(height: 8),
          Expanded(
            child: activitiesAsync.when(
              data: (activities) => _buildContent(activities, batches),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, stack) => const Center(
                child: Text('Failed to load activities', style: TextStyle(color: Color(0xFF9CA3AF))),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(List<ActivityLogItem> activities, List<dynamic> batches) {
    if (activities.isEmpty) {
      return const Center(
        child: Text('No activities yet', style: TextStyle(color: Color(0xFF9CA3AF))),
      );
    }

    return ListView.separated(
      itemCount: activities.length,
      padding: EdgeInsets.zero,
      physics: const ClampingScrollPhysics(),
      itemBuilder: (context, index) {
        final activity = activities[index];
        return _buildRow(activity, batches);
      },
      separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFE5E7EB)),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: const [
          Expanded(flex: 4, child: Text('Description', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF9CA3AF)))),
          Expanded(child: Text('Category', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF9CA3AF)))),
          Expanded(child: Text('Status', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF9CA3AF)))),
          Expanded(child: Text('Date', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF9CA3AF)))),
        ],
      ),
    );
  }

  Widget _buildRow(ActivityLogItem activity, List<dynamic> batches) {
    final iconColor = activity.statusColor;
    final icon = activity.icon;

    // Lookup batch display name
    String? batchDisplayName = activity.batchName ?? activity.batchId;
    if (activity.batchName == null && activity.batchId != null) {
      final matchingBatches = batches.where((b) => b.id == activity.batchId);
      if (matchingBatches.isNotEmpty) {
        batchDisplayName = matchingBatches.first.displayName;
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 18, color: iconColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        activity.title,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF374151),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      
                      // Machine and Batch info row
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          if (activity.machineName != null || activity.machineId != null)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: Colors.blue.shade200, width: 0.5),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.precision_manufacturing, size: 10, color: Colors.blue.shade700),
                                  const SizedBox(width: 4),
                                  Text(
                                    activity.machineName ?? activity.machineId ?? '',
                                    style: TextStyle(fontSize: 10, color: Colors.blue.shade700),
                                  ),
                                ],
                              ),
                            ),
                          if (batchDisplayName != null)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.purple.shade50,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: Colors.purple.shade200, width: 0.5),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.inventory_2_outlined, size: 10, color: Colors.purple.shade700),
                                  const SizedBox(width: 4),
                                  Text(
                                    batchDisplayName,
                                    style: TextStyle(fontSize: 10, color: Colors.purple.shade700),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      
                      // Operator name
                      Text(
                        activity.operatorName != null && activity.operatorName!.isNotEmpty
                            ? activity.operatorName!
                            : 'System',
                        style: const TextStyle(
                          fontSize: 10,
                          color: Color(0xFF9CA3AF),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Text(
              _getCategoryText(activity),
              style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
            ),
          ),
          Expanded(
            child: Text(
              _getStatusText(activity),
              style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280), fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              _formatDate(activity.timestamp),
              style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
            ),
          ),
        ],
      ),
    );
  }

  String _getCategoryText(ActivityLogItem log) {
    switch (log.type) {
      case ActivityType.substrate:
        return 'Substrate';
      case ActivityType.alert:
        return 'Alert';
      case ActivityType.report:
        return log.reportType ?? 'Report';
      case ActivityType.cycle:
        return log.controllerType == 'drum_controller' ? 'Drum' : 'Aerator';
    }
  }

  String _getStatusText(ActivityLogItem log) {
    if (log.isCycle) return log.status?.toUpperCase() ?? 'COMPLETED';
    if (log.type == ActivityType.report) {
      return log.priority?.toUpperCase() ?? 'OPEN';
    }
    return 'COMPLETED';
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    if (difference.inDays == 0) return 'Today';
    if (difference.inDays == 1) return 'Yesterday';
    return '${date.month}/${date.day}';
  }
}