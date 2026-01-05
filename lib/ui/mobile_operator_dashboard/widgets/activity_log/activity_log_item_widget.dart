import 'package:flutter/material.dart';
import '../../../../data/models/activity_log_item.dart';

/// Widget to display a single activity log item
class ActivityLogItemWidget extends StatelessWidget {
  final ActivityLogItem log;

  const ActivityLogItemWidget({super.key, required this.log});

  @override
  Widget build(BuildContext context) {
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
                // Title
                Text(
                  log.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Color(0xFF1F2937),
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                
                // Username
                Text(
                  log.operatorName != null && log.operatorName!.isNotEmpty 
                      ? log.operatorName! 
                      : 'System',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF9CA3AF),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                
                const SizedBox(height: 12),

                // Info Row: Category - Status - Date
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Category
                    /*
                    Flexible(
                      child: Text(
                        _getCategoryText(log),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    */
                    // Using direct mapped text or similar logic if redundant
                     Text(
                        _getCategoryText(log),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      
                    // Status
                    Text(
                      _getStatusText(log),
                       style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                          fontWeight: FontWeight.w500,
                        ),
                    ),

                    // Date
                    Text(
                      _formatDate(log.timestamp),
                      style: const TextStyle(
                        fontSize: 12,
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