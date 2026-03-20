// lib/ui/web_admin_home/widgets/recent_activities_table.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/providers/activity_providers.dart';
import '../../../data/providers/batch_providers.dart';
import '../../../data/models/activity_log_item.dart';

class RecentActivitiesTable extends ConsumerWidget {
  final String? machineId;
  final bool hideHeader;
  final bool isCondensed;

  const RecentActivitiesTable({
    super.key,
    this.machineId,
    this.hideHeader = false,
    this.isCondensed = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Use future provider for one-time fetch 
    final activitiesAsync = ref.watch(allActivitiesProvider);
    final batchesAsync = ref.watch(userTeamBatchesProvider);
    final batches = batchesAsync.value ?? [];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderTitleRow(ref),
              const SizedBox(height: 20),
              if (!hideHeader) ...[
                _buildHeader(),
                const Divider(height: 1, color: Color(0xFFE5E7EB)),
                const SizedBox(height: 8),
              ],
              Expanded(
                child: activitiesAsync.when(
                  data: (activities) => _buildContent(activities, batches),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (_, stack) => const Center(
                    child: Text(
                      'Failed to load activities',
                      style: TextStyle(color: Color(0xFF9CA3AF)),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildContent(
    List<ActivityLogItem> activities,
    List<dynamic> batches, {
    bool shrinkWrap = false,
  }) {
    final filteredActivities = machineId != null
        ? activities.where((a) => a.machineId == machineId).toList()
        : activities;

    if (filteredActivities.isEmpty) {
      return const Center(
        child: Text(
          'No activities yet',
          style: TextStyle(color: Color(0xFF9CA3AF)),
        ),
      );
    }

    // ✅ NEW: Constant time lookup map to reduce N+1 performance bottleneck
    final Map<String, String> batchNameLookup = {};
    for (var b in batches) {
      if (b.id != null) {
        batchNameLookup[b.id] = b.displayName ?? b.id;
      }
    }

    return ListView.separated(
      itemCount: filteredActivities.length,
      padding: EdgeInsets.zero,
      shrinkWrap: shrinkWrap,
      physics: shrinkWrap
          ? const NeverScrollableScrollPhysics()
          : const ClampingScrollPhysics(),
      itemBuilder: (context, index) {
        final activity = filteredActivities[index];
        return _buildRow(activity, batchNameLookup);
      },
      separatorBuilder: (context, index) =>
          const Divider(height: 1, color: Color(0xFFE5E7EB)),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            flex: isCondensed ? 4 : 3,
            child: const Text(
              'Description',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFF9CA3AF),
              ),
            ),
          ),
          if (!isCondensed) ...[
            const Expanded(
              flex: 2,
              child: Text(
                'Machine / Batch',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF9CA3AF),
                ),
              ),
            ),
            const Expanded(
              flex: 2,
              child: Text(
                'Status',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF9CA3AF),
                ),
              ),
            ),
          ],
          Expanded(
            flex: 1,
            child: const Text(
              'Date',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFF9CA3AF),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderTitleRow(WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Recent Activities',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.refresh, size: 16),
          // ✅ Clear cache and invalidate provider to force refresh
          onPressed: () {
            ref.read(activityAggregatorProvider).clearCache();
            ref.invalidate(allActivitiesProvider);
          },
          tooltip: 'Refresh',
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ],
    );
  }

  Widget _buildRow(ActivityLogItem activity, Map<String, String> batchNameLookup) {
    final iconColor = activity.statusColor;
    final icon = activity.icon;

    // Lookup batch display name using constant-time map
    String? batchDisplayName = activity.batchName ?? activity.batchId;
    if (activity.batchName == null && activity.batchId != null) {
      final name = batchNameLookup[activity.batchId];
      if (name != null) {
        batchDisplayName = name;
      }
    }

    final machineText = activity.machineName ?? activity.machineId ?? '';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: isCondensed ? 4 : 3,
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
                      // Operator name
                      Text(
                        activity.operatorName != null &&
                                activity.operatorName!.isNotEmpty
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
          if (!isCondensed) ...[
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Machine name
                  Text(
                    machineText.isNotEmpty ? machineText : '—',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF374151),
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (batchDisplayName != null &&
                      batchDisplayName.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    // Batch name
                    Text(
                      batchDisplayName,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFF9CA3AF),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                _getStatusText(activity),
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF6B7280),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
          Expanded(
            flex: 1,
            child: Text(
              _formatDate(activity.timestamp),
              textAlign: TextAlign.end,
              style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
            ),
          ),
        ],
      ),
    );
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
