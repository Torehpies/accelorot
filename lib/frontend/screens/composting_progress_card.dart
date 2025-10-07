// lib/screens/composting_progress.dart
import 'package:flutter/material.dart';

class CompostingProgressCard extends StatelessWidget {
  final DateTime batchStart;
  static const int totalDays = 12; // Fixed 12-day cycle

  const CompostingProgressCard({
    super.key,
    required this.batchStart,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    // ⚠️ Use .inDays → truncates partial days (matches CSV: 0.08 = 0 days)
    final daysPassed = now.difference(batchStart).inDays.clamp(0, totalDays);
    final progress = daysPassed / totalDays; // 0.0 to 1.0
    final daysLeft = (totalDays - daysPassed).clamp(0, totalDays);

    return SizedBox(
      width: 400,
      height: 150,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Composting Progress',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 3),
              const Divider(thickness: 1.5, color: Colors.green),
              const SizedBox(height: 6),

              Row(
                children: [
                  const Text(
                    'Decomposition',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const Spacer(),
                  Text(
                    '${(progress * 100).toInt()}%',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 3),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                minHeight: 7,
                borderRadius: BorderRadius.circular(8),
              ),
              const SizedBox(height: 10),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildBatchStartColumn(daysPassed),
                  _buildEstCompletionColumn(daysLeft),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBatchStartColumn(int daysPassed) {
    String timeText;
    if (daysPassed == 0) {
      timeText = 'Today';
    } else if (daysPassed == 1) {
      timeText = '1 day ago';
    } else {
      timeText = '$daysPassed days ago';
    }

    // Format the actual batch start date
    String formattedDate = _formatDate(batchStart);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Batch Start', style: TextStyle(fontSize: 11, color: Colors.grey)),
        const SizedBox(height: 2),
        Text(
          '$formattedDate – $timeText',
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildEstCompletionColumn(int daysLeft) {
    String timeText;
    if (daysLeft == 0) {
      timeText = 'Completed';
    } else if (daysLeft == 1) {
      timeText = '1 day left';
    } else {
      timeText = '$daysLeft days left';
    }

    // Estimated completion = start + 12 days
    final estCompletion = batchStart.add(const Duration(days: totalDays));
    String formattedDate = _formatDate(estCompletion);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Est Completion', style: TextStyle(fontSize: 11, color: Colors.grey)),
        const SizedBox(height: 2),
        Text(
          '$formattedDate – $timeText',
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final monthNames = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${monthNames[date.month - 1]} ${date.day}, ${date.year}';
  }
}