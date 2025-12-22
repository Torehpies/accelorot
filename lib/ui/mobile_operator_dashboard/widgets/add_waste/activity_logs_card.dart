// lib/frontend/operator/dashboard/add_waste/activity_logs_card.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/models/activity_log_item.dart';
import '../../../../data/providers/activity_providers.dart';
import '../../../../data/providers/batch_providers.dart'; 

/// Modern table-style activity logs card with proper field mapping
class ActivityLogsCard extends ConsumerWidget {
  final String? focusedMachineId;

  const ActivityLogsCard({super.key, this.focusedMachineId});

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Just now';
        }
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      final monthNames = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
      ];
      return '${monthNames[date.month - 1]} ${date.day}';
    }
  }

  /// Get status text based on activity type
  String _getStatusText(ActivityLogItem log) {
    // For cycles, show running/completed status
    if (log.isCycle && log.status != null) {
      return log.status!.toUpperCase();
    }
    
    // For reports, show priority or status
    if (log.type == ActivityType.report) {
      return log.priority?.toUpperCase() ?? log.status?.toUpperCase() ?? 'OPEN';
    }
    
    // For alerts, show status
    if (log.type == ActivityType.alert) {
      return log.status?.toUpperCase() ?? 'ACTIVE';
    }
    
    // For substrates, default to completed
    return 'COMPLETED';
  }

  /// Get category text with better formatting
  String _getCategoryText(ActivityLogItem log) {
    switch (log.type) {
      case ActivityType.substrate:
        return 'Substrate';
      case ActivityType.alert:
        return 'Alert';
      case ActivityType.report:
        return log.reportType ?? 'Report';
      case ActivityType.cycle:
        return log.controllerType == 'drum_controller' 
            ? 'Drum Controller' 
            : 'Aerator';
    }
  }

  /// Get status color based on type
 /*
  Color _getStatusColor(ActivityLogItem log) {
    if (log.isCycle) {
      if (log.isRunning) return Colors.blue;
      if (log.isCompleted) return Colors.green;
    }
    
    if (log.type == ActivityType.report) {
      switch (log.priority?.toLowerCase()) {
        case 'high':
        case 'critical':
          return Colors.red;
        case 'medium':
          return Colors.orange;
        case 'low':
        default:
          return Colors.blue;
      }
    }
    
    if (log.type == ActivityType.alert) {
      return Colors.orange;
    }
    
    return Colors.green;
  }
  */

    String? _getBatchDisplayName(WidgetRef ref, String? batchId) {
    if (batchId == null || batchId.isEmpty) return null;
    
    final batchesAsync = ref.watch(userTeamBatchesProvider);
    return batchesAsync.maybeWhen(
      data: (batches) {
        final batch = batches.firstWhere(
          (b) => b.id == batchId,
          orElse: () => batches.first, // Fallback
        );
        return batch.displayName;
      },
      orElse: () => null,
    );
  }


  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activitiesAsync = ref.watch(allActivitiesProvider);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.08),
            spreadRadius: 0,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(24.0),
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
                ),
              ],
            ),
          ),

          // Table Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              border: Border(
                top: BorderSide(color: Colors.grey.shade200, width: 1),
                bottom: BorderSide(color: Colors.grey.shade200, width: 1),
              ),
            ),
            child: Row(
              children: const [
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
          ),

          // Content
          Expanded(
            child: activitiesAsync.when(
              data: (allLogs) => _buildContent(context, ref, allLogs), 
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

  Widget _buildContent(BuildContext context, WidgetRef ref, List<ActivityLogItem> allLogs) {
    if (allLogs.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.inbox_outlined,
                size: 48,
                color: Colors.grey.shade300,
              ),
              const SizedBox(height: 12),
              Text(
                focusedMachineId != null
                    ? 'No activity logs for this machine yet.'
                    : 'No logs yet. Add waste or submit a report to get started!',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF9CA3AF),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Filter by machine if needed
    final filteredLogs = focusedMachineId != null
        ? allLogs.where((log) => log.machineId == focusedMachineId).toList()
        : allLogs;

    if (filteredLogs.isEmpty && focusedMachineId != null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Text(
            'No activity logs for this machine yet.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF9CA3AF),
              fontSize: 14,
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: filteredLogs.length,
      padding: EdgeInsets.zero,
      physics: const ClampingScrollPhysics(),
      itemBuilder: (context, index) {
        final log = filteredLogs[index];
        //final statusColor = _getStatusColor(log);
        final batchDisplayName = _getBatchDisplayName(ref, log.batchId);


        return Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Colors.grey.shade100,
                width: 1,
              ),
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
                    color: log.statusColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    log.icon,
                    color: Colors.white,
                    size: 20,
                  ),
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
                      const SizedBox(height: 4),
                      
                      // ✅ UPDATED: Show cycles count (not status) + operator
                      Row(
                        children: [
                          // For cycles: show cycle count from value field
                          // For substrates: show quantity
                          // For alerts/reports: show their value
                          Text(
                            log.value, // e.g., "5 cycles", "15kg", etc.
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF6B7280),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          
                          // ✅ Show operator name
                          if (log.operatorName != null && log.operatorName!.isNotEmpty) ...[
                            const Text(' • ', style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 12)),
                            Flexible(
                              child: Text(
                                log.operatorName!,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF6B7280),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ],
                      ),
                      
                      // Show machine + batch info
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          // Machine name/ID
                          if (log.machineName != null || log.machineId != null) ...[
                            Icon(Icons.precision_manufacturing, size: 12, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                log.machineName ?? log.machineId ?? '',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[600],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                          
                          // ✅ UPDATED: Batch display name (not ID)
                          if (batchDisplayName != null && batchDisplayName.isNotEmpty) ...[
                            const Text(' • ', style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 11)),
                            Icon(Icons.inventory_2, size: 12, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                batchDisplayName, // ✅ Show display name instead of ID
                                style: TextStyle(
                                  fontSize: 11,
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

                // Status Badge
                 Expanded(
                  flex: 2,
                  child: Text(
                    _getStatusText(log),
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF6B7280),
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // Date
                Expanded(
                  flex: 2,
                  child: Text(
                    _formatDate(log.timestamp),
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF6B7280),
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 12),
            const Text(
              'Failed to load activities',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF9CA3AF),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}