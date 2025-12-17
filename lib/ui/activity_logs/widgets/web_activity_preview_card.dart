// lib/ui/activity_logs/widgets/web_activity_preview_card.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/models/activity_log_item.dart';

/// Compact preview card for dashboard sections
/// Design matches Image 2 style - clean and minimal
class WebActivityPreviewCard extends StatelessWidget {
  final ActivityLogItem item;

  const WebActivityPreviewCard({
    super.key,
    required this.item,
  });

  String _formatRelativeTime(DateTime timestamp) {
    final now = DateTime.now();
    final diff = now.difference(timestamp);

    if (diff.inDays == 0) {
      return DateFormat('h:mm a').format(timestamp);
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} days ago';
    } else {
      return DateFormat('MMM d').format(timestamp);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: CircleAvatar(
        radius: 16,
        backgroundColor: item.statusColor,
        child: Icon(
          item.icon,
          color: Colors.white,
          size: 16,
        ),
      ),
      title: Text(
        item.title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Color(0xFF302F2F),
        ),
      ),
      subtitle: Text(
        '${item.value} • ${item.machineName ?? item.machineId ?? 'Unknown'} • ${item.operatorName ?? 'Unknown'}',
        style: const TextStyle(
          fontSize: 13,
          color: Colors.grey,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Text(
        _formatRelativeTime(item.timestamp),
        style: const TextStyle(
          fontSize: 13,
          color: Colors.grey,
        ),
      ),
    );
  }
}