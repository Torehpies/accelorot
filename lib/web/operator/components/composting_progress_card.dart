// lib/web/operator/components/composting_progress_card.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CompostingProgressCard extends StatelessWidget {
  const CompostingProgressCard({super.key});

  @override
  Widget build(BuildContext context) {
    final progress = 45.0;
    final startDate = DateTime(2025, 8, 30);
    final endDate = DateTime(2025, 9, 5);
    final now = DateTime.now();
    final daysFromStart = now.difference(startDate).inDays;
    final daysLeft = endDate.difference(now).inDays;
    final daysLeftText = daysLeft > 0 ? '${daysLeft}days left' : 'Completed';

    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                Icon(Icons.pie_chart_outline, color: Colors.grey[700], size: 18),
                const SizedBox(width: 8),
                Text(
                  'Composting Progress',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Decomposition label and percentage
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Decomposition',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '${progress.toInt()}%',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            // Progress Bar
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress / 100,
                backgroundColor: Colors.grey[200],
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFFA726)),
                minHeight: 16,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Dates Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Batch Start
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Batch Start',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${DateFormat('MMM dd, yyyy').format(startDate)} - ${daysFromStart}day ago',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[900],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                
                // Est Completion with green indicator
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Est Completion',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${DateFormat('MMM dd, yyyy').format(endDate)} - $daysLeftText',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[900],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 12),
                    Container(
                      width: 24,
                      height: 48,
                      decoration: BoxDecoration(
                        
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}