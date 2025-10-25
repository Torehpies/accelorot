// lib/web/operator/components/composting_progress_card.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CompostingProgressCard extends StatelessWidget {
  const CompostingProgressCard({super.key});

  @override
  Widget build(BuildContext context) {
    final progress = 45.0;
    final startDate = DateTime(2025, 8, 30);
    final endDate = startDate.add(const Duration(days: 10));

    // ignore: prefer_typing_uninitialized_variables
    var daysLeftd;
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(Icons.recycling, color: Colors.teal, size: 18),
                const SizedBox(width: 6),
                Text(
                  'Composting Progress',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Decomposition', style: TextStyle(fontSize: 10, color: Colors.grey[600])),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: progress / 100,
                        backgroundColor: Colors.grey[200],
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.orange),
                        minHeight: 8,
                      ),
                      const SizedBox(height: 4),
                      Text('$progress% Complete', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Batch Start: ${DateFormat('MMM dd').format(startDate)}',
                        style: const TextStyle(fontSize: 10),
                        textAlign: TextAlign.right,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Est Completion: ${DateFormat('MMM dd').format(endDate)} • $daysLeftd',
                        style: const TextStyle(fontSize: 10),
                        textAlign: TextAlign.right,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}