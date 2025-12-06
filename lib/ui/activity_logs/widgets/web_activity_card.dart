// lib/ui/activity_logs/widgets/web_activity_card.dart

import 'package:flutter/material.dart';
import '../../../data/models/activity_log_item.dart';

/// Individual activity card in ListTile style
class WebActivityCard extends StatelessWidget {
  final ActivityLogItem item;

  const WebActivityCard({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      leading: CircleAvatar(
        radius: 16,
        backgroundColor: item.statusColor,
        child: Icon(
          item.icon,
          color: Colors.white,
          size: 16,
        ),
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              item.title,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF302F2F),
              ),
            ),
          ),
          Text(
            item.value,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.grey,
            ),
          ),
        ],
      ),
      subtitle: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              '${item.category} • Machine: ${item.machineName ?? item.machineId ?? '-'} | By: ${item.operatorName ?? '-'}',
              style: const TextStyle(
                fontSize: 13,
                color: Colors.grey,
              ),
            ),
          ),
          Text(
            item.formattedTimestamp,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}