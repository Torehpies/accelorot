import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/models/activity_log_item.dart';
import '../../../../data/providers/batch_providers.dart';

/// Widget to display a single activity log item
class ActivityLogItemWidget extends ConsumerWidget {
  final ActivityLogItem log;

  const ActivityLogItemWidget({super.key, required this.log});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Try to find batch name from provider if missing in log
    final batchesAsync = ref.watch(userTeamBatchesProvider);
    String? batchDisplayName = log.batchName ?? log.batchId;

    if (log.batchName == null && log.batchId != null) {
      batchesAsync.whenData((batches) {
        final matchingBatches = batches.where((b) => b.id == log.batchId);
        if (matchingBatches.isNotEmpty) {
          batchDisplayName = matchingBatches.first.displayName;
        }
      });
    }
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: log.statusColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(log.icon, color: log.statusColor, size: 24),
          ),
          const SizedBox(width: 16),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and Value Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Expanded(
                      child: Text(
                        log.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: Color(0xFF1F2937),
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Value (aligned right)
                    if (log.value.isNotEmpty)
                      Text(
                        log.value,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 3),

                // Machine and Batch Row
                Row(
                  children: [
                    if (log.machineName != null || log.machineId != null) ...[
                      Icon(
                        Icons.precision_manufacturing,
                        size: 10,
                        color: Colors.grey[500],
                      ),
                      const SizedBox(width: 3),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 80),
                        child: Text(
                          log.machineName ?? log.machineId ?? '',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],

                    if ((log.machineName != null || log.machineId != null) && 
                        (log.batchName != null || log.batchId != null)) ...[
                      const SizedBox(width: 6),
                      Text(
                        '•',
                        style: TextStyle(color: Colors.grey[400], fontSize: 10),
                      ),
                      const SizedBox(width: 6),
                    ],

                    if (log.batchName != null || log.batchId != null) ...[
                      Flexible(
                        child: Text(
                          batchDisplayName ?? '',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
                
                const SizedBox(height: 3),

                // Operator Name
                Text(
                  log.operatorName != null && log.operatorName!.isNotEmpty 
                      ? log.operatorName! 
                      : 'System',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[500],
                  ),
                ),
                
                const SizedBox(height: 6),

                // Info Row: Category - Status - Date
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Category
                    Text(
                      _getCategoryText(log),
                      style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFF6B7280),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                      
                    // Status
                    Text(
                      _getStatusText(log),
                      style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFF6B7280),
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    // Date
                    Text(
                      _formatDate(log.timestamp),
                      style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFF9CA3AF),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods to match the logic from ActivityLogsCard if needed, 
  // or use existing ones if available. 
  // Since ActivityLogItemWidget is stateless and independent, we should include helpers here or import them.
  // The user provided ActivityLogsHelpers.dart but it doesn't have all methods.
  // I will implement simple versions here for self-containment or copy from ActivityLogsCard.
  
  String _getCategoryText(ActivityLogItem log) {
    if (log.type == ActivityType.substrate) return 'Substrate';
    if (log.type == ActivityType.alert) return 'Alert';
    if (log.type == ActivityType.report) return log.reportType ?? 'Report';
    if (log.type == ActivityType.cycle) {
      return log.controllerType == 'drum_controller' ? 'Drum' : 'Aerator';
    }
    return 'Activity';
  }

  String _getStatusText(ActivityLogItem log) {
    if (log.isCycle && log.status != null) return log.status!.toUpperCase();
    if (log.type == ActivityType.report) {
      return log.priority?.toUpperCase() ?? log.status?.toUpperCase() ?? 'OPEN';
    }
    if (log.type == ActivityType.alert) return log.status?.toUpperCase() ?? 'ACTIVE';
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