// lib/frontend/operator/dashboard/add_waste/activity_logs_card.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../services/firestore_activity_service.dart';
import '../../../../frontend/operator/activity_logs/models/activity_item.dart';

class ActivityLogsCard extends StatefulWidget {
  final String? focusedMachineId;

  const ActivityLogsCard({super.key, this.focusedMachineId});

  @override
  State<ActivityLogsCard> createState() => ActivityLogsCardState();
}

class ActivityLogsCardState extends State<ActivityLogsCard> {
  bool _loading = true;
  bool _logsFetchError = false;
  List<ActivityItem> _allLogs = [];

  @override
  void initState() {
    super.initState();
    _fetchAllLogs();
  }

  Future<void> refresh() async {
    await _fetchAllLogs();
  }

  Future<void> _fetchAllLogs() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      if (mounted) {
        setState(() {
          _loading = false;
          _logsFetchError = true;
          _allLogs.clear();
        });
      }
      return;
    }

    try {
      setState(() => _loading = true);

      final logs = await FirestoreActivityService.getAllActivities();

      if (mounted) {
        setState(() {
          _allLogs = logs;
          _loading = false;
          _logsFetchError = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _logsFetchError = true;
          _allLogs.clear();
        });
      }
    }
  }

  Color _getActivityColor(ActivityItem log) {
    if (log.isReport) {
      // Report colors based on priority
      switch (log.priority?.toLowerCase()) {
        case 'high':
          return const Color(0xFFEF4444); // Red
        case 'medium':
          return const Color(0xFFF59E0B); // Orange
        case 'low':
          return const Color(0xFF10B981); // Green
        default:
          return const Color(0xFF06B6D4); // Cyan
      }
    } else {
      // Waste product colors based on category
      switch (log.category.toLowerCase()) {
        case 'vegetable':
          return const Color(0xFF10B981); // Green
        case 'fruit':
          return const Color(0xFFF59E0B); // Orange
        case 'meat':
          return const Color(0xFFEF4444); // Red
        case 'grain':
          return const Color(0xFF8B5CF6); // Purple
        default:
          return const Color(0xFF6B7280); // Gray
      }
    }
  }

  IconData _getActivityIcon(ActivityItem log) {
    if (log.isReport) {
      switch (log.reportType?.toLowerCase()) {
        case 'maintenance_issue':
          return Icons.build_outlined;
        case 'observation':
          return Icons.visibility_outlined;
        case 'safety_concern':
          return Icons.warning_outlined;
        default:
          return Icons.description_outlined;
      }
    } else {
      return Icons.delete_outline;
    }
  }

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

  String _getStatusText(ActivityItem log) {
    if (log.isReport) {
      return log.status ?? 'Open';
    } else {
      return 'Completed';
    }
  }

  String _getCategoryText(ActivityItem log) {
    if (log.isReport) {
      switch (log.reportType?.toLowerCase()) {
        case 'maintenance_issue':
          return 'Maintenance';
        case 'observation':
          return 'Observation';
        case 'safety_concern':
          return 'Safety';
        default:
          return 'Report';
      }
    } else {
      return log.category;
    }
  }

  @override
  Widget build(BuildContext context) {
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
            padding: const EdgeInsets.all(20.0),
            child: const Text(
              'Recent Activities',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1a1a1a),
                letterSpacing: -0.5,
              ),
            ),
          ),

          // Table Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              border: Border(
                top: BorderSide(color: Colors.grey.shade200, width: 1),
                bottom: BorderSide(color: Colors.grey.shade200, width: 1),
              ),
            ),
            child: Row(
              children: [
                const Expanded(
                  flex: 4,
                  child: Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF6B7280),
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const Expanded(
                  flex: 2,
                  child: Text(
                    'Category',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF6B7280),
                      letterSpacing: 0.5,
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
                      color: Color(0xFF6B7280),
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const Expanded(
                  flex: 2,
                  child: Text(
                    'Date',
                    style: TextStyle(
                      fontSize: 11,
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
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
        ),
      );
    } else if (_logsFetchError || _allLogs.isEmpty) {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Text(
              'Please log in to view recent logs.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF9CA3AF),
                fontSize: 13,
              ),
            ),
          ),
        );
      } else {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.inbox_outlined,
                  size: 40,
                  color: Colors.grey.shade300,
                ),
                const SizedBox(height: 10),
                Text(
                  widget.focusedMachineId != null
                      ? 'No activity logs for this machine yet.'
                      : 'No logs yet. Add waste or submit a report to get started!',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF9CA3AF),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        );
      }
    } else {
      final filteredLogs = widget.focusedMachineId != null
          ? _allLogs
              .where((log) => log.machineId == widget.focusedMachineId)
              .toList()
          : _allLogs;

      if (filteredLogs.isEmpty && widget.focusedMachineId != null) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Text(
              'No activity logs for this machine yet.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF9CA3AF),
                fontSize: 13,
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
          final color = _getActivityColor(log);
          final icon = _getActivityIcon(log);

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
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  // Icon
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      icon,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Description
                  Expanded(
                    flex: 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          log.description.isNotEmpty 
                              ? log.description 
                              : log.title,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF1a1a1a),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          log.operatorName ?? 'Unknown',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF9CA3AF),
                          ),
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
                        fontSize: 12,
                        color: Color(0xFF6B7280),
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
                        fontSize: 12,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ),

                  // Date
                  Expanded(
                    flex: 2,
                    child: Text(
                      _formatDate(log.timestamp),
                      style: const TextStyle(
                        fontSize: 12,
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
  }
}