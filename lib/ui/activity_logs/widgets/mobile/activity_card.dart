// lib/ui/activity_logs/widgets/mobile/activity_card.dart

import 'package:flutter/material.dart';
import '../../../core/widgets/sample_cards/data_card.dart';
import '../../../../data/models/activity_log_item.dart';

/// Activity card that uses DataCard for consistent styling across the app
/// This is a semantic wrapper that handles ActivityLogItem → DataCard field mapping
class ActivityCard extends StatelessWidget {
  final ActivityLogItem item;
  final VoidCallback? onTap;

  const ActivityCard({
    super.key,
    required this.item,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: DataCard<ActivityLogItem>(
        // Icon styling - circular background with status color
        icon: item.icon,
        iconColor: Colors.white,
        iconBgColor: item.statusColor.withValues(alpha: 0.2),
        
        // Content
        title: item.title,
        description: item.description,
        
        // Category badge (top-right corner)
        category: item.category,
        
        // Status pill (bottom-left) - Shows cycle progress or regular value
        status: _getStatusText(),
        statusColor: item.statusColor.withValues(alpha: 0.15),
        statusTextColor: item.statusColor,
        
        // User info (bottom-right)
        userName: item.operatorName,
        
        // Data and interaction
        data: item,
        onTap: onTap,
      ),
    );
  }

  /// Get the status text - either cycle progress (X/Y) or regular value
  String _getStatusText() {
    if (item.isCycle && item.cycles != null) {
      return '${item.completedCycles ?? 0}/${item.cycles}';
    }
    return item.value;
  }
}