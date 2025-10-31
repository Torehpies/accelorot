// lib/frontend/operator/dashboard/compost_progress/composting_progress_card.dart
import 'package:flutter/material.dart';
import 'components/batch_id_dialog.dart';
import 'components/compost_batch_detail_dialog.dart';

class CompostingProgressCard extends StatefulWidget {
  const CompostingProgressCard({super.key});

  @override
  State<CompostingProgressCard> createState() => _CompostingProgressCardState();
}

class _CompostingProgressCardState extends State<CompostingProgressCard> {
  static const int totalDays = 12; // Fixed 12-day cycle
  
  // State management
  bool isStarted = false;
  String batchId = '';
  DateTime? batchStart;

  // Start batch - opens dialog to get Batch ID
  void _startBatch() async {
    final batch = await showDialog<String>(
      context: context,
      builder: (ctx) => BatchIdDialog(),
    );
    if (batch != null && batch.isNotEmpty) {
      setState(() {
        isStarted = true;
        batchId = batch;
        batchStart = DateTime.now();
      });
    }
  }

  // Show detailed view dialog
  void _showDetailsDialog() {
    showDialog(
      context: context,
      builder: (ctx) => CompostBatchDetailDialog(
        batchId: batchId,
        batchStart: batchStart,
        onComplete: () {
          setState(() {
            isStarted = false;
            batchId = '';
            batchStart = null;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final progress = 0.10; // Static 10% green progress

    return GestureDetector(
      onTap: isStarted ? _showDetailsDialog : null,
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
                      Icon(Icons.compost_outlined, color: Colors.green.shade700, size: 20),
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
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green.shade300),
                      ),
                      child: Text(
                        'Active',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green.shade700,
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
                      color: Colors.green.shade700,
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
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.green.shade600),
                  minHeight: 8,
                ),
              ),
              const SizedBox(height: 16),

              // Conditional content based on start state
              if (!isStarted)
                Center(
                  child: ElevatedButton.icon(
                    onPressed: _startBatch,
                    icon: const Icon(Icons.play_arrow, size: 18),
                    label: const Text(
                      'Start Composting',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade700,
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
                        _buildInfoColumn('Batch ID', batchId),
                        _buildInfoColumn('Batch Start', _formatDateShort(batchStart)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildInfoColumn('Days Passed', _getDaysPassed()),
                        _buildInfoColumn('Est Completion', 'null'),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.info_outline, size: 16, color: Colors.blue.shade700),
                          const SizedBox(width: 6),
                          Text(
                            'Tap card for details',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
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
    return Column(
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
        ),
      ],
    );
  }

  String _getDaysPassed() {
    if (batchStart == null) return '0';
    final now = DateTime.now();
    final daysPassed = now.difference(batchStart!).inDays.clamp(0, totalDays);
    return '$daysPassed days';
  }

  String _formatDateShort(DateTime? date) {
    if (date == null) return '-';
    final monthNames = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${monthNames[date.month - 1]} ${date.day}';
  }
}
