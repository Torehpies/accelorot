// lib/ui/activity_logs/widgets/activity_card.dart

import 'package:flutter/material.dart';
import '../../../../data/models/activity_log_item.dart';

class ActivityCard extends StatelessWidget {
  final ActivityLogItem item;  

  const ActivityCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title and Status + Value
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: item.statusColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    // Show cycle progress
                    if (item.isCycle && item.cycles != null)
                      Text(
                        '${item.completedCycles ?? 0}/${item.cycles}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      )
                    else
                    Text(
                      item.value,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Icon and Description
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(item.icon, size: 40, color: Colors.teal),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item.description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Category, Machine, Batch, Operator and Timestamp
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Show machine info
                      Text(
                        'Machine: ${item.machineName ?? item.machineId ?? '-'}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black45,
                        ),
                      ),
                      // Show batch info
                      if (item.batchId != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            'Batch: ${item.batchId}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black45,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      // Show operator info
                      if (item.operatorName != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            'By: ${item.operatorName}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black45,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Text(
                  item.formattedTimestamp,
                  style: const TextStyle(fontSize: 12, color: Colors.black45),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}