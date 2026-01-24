// lib/ui/mobile_operator_dashboard/widgets/add_waste/activity_logs_web.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/models/activity_log_item.dart';
import '../../../../data/providers/activity_providers.dart';
import '../../../../data/providers/batch_providers.dart';

/// Web table-style activity logs view
class ActivityLogsWeb extends ConsumerWidget {
  const ActivityLogsWeb({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activitiesAsync = ref.watch(allActivitiesProvider);
    final batchesAsync = ref.watch(userTeamBatchesProvider);
    final batches = batchesAsync.value ?? [];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          _buildHeader(ref),
          _buildTableHeader(),
          Expanded(
            child: activitiesAsync.when(
              data: (allLogs) => _buildContent(allLogs, batches),
              loading: () => const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
                ),
              ),
              error: (error, stack) => _buildErrorState(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 16, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Recent Activities',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1a1a1a),
              letterSpacing: -0.5,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh, size: 20),
            onPressed: () {
              ref.invalidate(allActivitiesProvider);
            },
            tooltip: 'Refresh',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
      ),
      child: const Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(
              'Description',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6B7280),
                letterSpacing: 0.5,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Category',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6B7280),
                letterSpacing: 0.5,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Status',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6B7280),
                letterSpacing: 0.5,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Date',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6B7280),
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(List<ActivityLogItem> allLogs, List<dynamic> batches) {
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
        return _buildTableRow(log, batches);
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

  Widget _buildTableRow(ActivityLogItem log, List<dynamic> batches) {
    // Lookup batch display name
    String batchDisplayName = log.batchName ?? log.batchId ?? '';
    if (log.batchName == null && log.batchId != null) {
      final matchingBatches = batches.where((b) => b.id == log.batchId);
      if (matchingBatches.isNotEmpty) {
        batchDisplayName = matchingBatches.first.displayName;
      }
    }

    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade100, width: 1),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          children: [
            // Icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: log.statusColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(log.icon, color: log.statusColor, size: 20),
            ),
            const SizedBox(width: 16),

            // Description Column
            Expanded(
              flex: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    log.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1a1a1a),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  // Value (kg/running)
                  if (log.value.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      log.value,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],

                  const SizedBox(height: 4),

                  // Machine • Batch • Operator
                  Row(
                    children: [
                      if (log.machineName != null || log.machineId != null) ...[
                        Text(
                          log.machineName ?? log.machineId ?? '',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                      if ((log.machineName != null || log.machineId != null) &&
                          batchDisplayName.isNotEmpty) ...[
                        Text(
                          ' • ',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 11,
                          ),
                        ),
                      ],
                      if (batchDisplayName.isNotEmpty)
                        Text(
                          batchDisplayName,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[500],
                          ),
                        ),
                      if (((log.machineName != null || log.machineId != null) ||
                              batchDisplayName.isNotEmpty) &&
                          (log.operatorName != null &&
                              log.operatorName!.isNotEmpty)) ...[
                        Text(
                          ' • ',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 11,
                          ),
                        ),
                      ],
                      Flexible(
                        child: Text(
                          log.operatorName ?? 'System',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[500],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Category
            Expanded(
              flex: 2,
              child: Text(
                _getCategoryText(log),
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF6B7280),
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // Status
            Expanded(
              flex: 2,
              child: Text(
                _getStatusText(log),
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF6B7280),
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // Date
            Expanded(
              flex: 2,
              child: Text(
                _formatDate(log.timestamp),
                style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper methods
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    if (difference.inDays == 0) return 'Today';
    if (difference.inDays == 1) return 'Yesterday';
    return '${date.month}/${date.day}';
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
    if (log.isCycle) return log.status?.toUpperCase() ?? '';
    if (log.type == ActivityType.report) {
      return log.priority?.toUpperCase() ?? 'OPEN';
    }
    return 'COMPLETED';
  }
}
