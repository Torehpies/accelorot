// lib/frontend/operator/dashboard/compost_progress/composting_progress_card.dart
import 'package:flutter/material.dart';
import '../../home_screen/compost_progress_components/batch_start_dialog.dart';
import '../../home_screen/compost_progress_components/batch_complete_dialog.dart';
import 'compost_batch_model.dart';

class CompostingProgressCard extends StatelessWidget {
  static const int totalDays = 12; // Fixed 12-day cycle

  final CompostBatch? currentBatch;
  final Function(CompostBatch) onBatchStarted;
  final VoidCallback onBatchCompleted;

  const CompostingProgressCard({
    super.key,
    required this.currentBatch,
    required this.onBatchStarted,
    required this.onBatchCompleted,
  });

  // Start batch - opens dialog to get batch info
  void _startBatch(BuildContext context) async {
    final batch = await showDialog<CompostBatch>(
      context: context,
      builder: (ctx) => const BatchStartDialog(),
    );

    if (batch != null) {
      onBatchStarted(batch);
    }
  }

  // Show detailed view dialog
  void _showDetailsDialog(BuildContext context) {
    if (currentBatch == null) return;

    showDialog(
      context: context,
      builder: (ctx) => BatchCompleteDialog(
        batch: currentBatch!,
        onComplete: onBatchCompleted,
      ),
    );
  }

  int _getDaysPassed() {
    if (currentBatch == null) return 0;
    final now = DateTime.now();
    return now.difference(currentBatch!.batchStart).inDays.clamp(0, totalDays);
  }

  double _getProgress() {
    return (_getDaysPassed() / totalDays).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final isStarted = currentBatch != null;
    final progress = _getProgress();

    return GestureDetector(
      onTap: isStarted ? () => _showDetailsDialog(context) : null,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300, width: 1.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.2),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.compost_outlined,
                        color: Colors.teal.shade700,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Composting Progress',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  if (isStarted)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.teal.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.teal.shade300),
                      ),
                      child: Text(
                        'Active',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.teal.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),

              // Decomposition progress row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Decomposition',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.black54,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '${(progress * 100).toInt()}%',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal.shade700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.teal.shade600,
                  ),
                  minHeight: 8,
                ),
              ),
              const SizedBox(height: 16),

              // Conditional content based on start state
              if (!isStarted)
                Center(
                  child: ElevatedButton.icon(
                    onPressed: () => _startBatch(context),
                    icon: const Icon(Icons.play_arrow, size: 18),
                    label: const Text(
                      'Start Composting',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal.shade700,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      elevation: 2,
                    ),
                  ),
                ),

              if (isStarted)
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildInfoColumn('Batch Name', currentBatch!.batchName),
                        _buildInfoColumn(
                          'Batch Number',
                          currentBatch!.batchNumber,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildInfoColumn(
                          'Started By',
                          currentBatch!.startedBy ?? 'null',
                        ),
                        _buildInfoColumn(
                          'Days Passed',
                          '${_getDaysPassed()} days',
                        ),
                      ],
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.black45,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
