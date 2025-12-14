// lib/frontend/operator/dashboard/compost_progress/components/batch_complete_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../mobile_operator_dashboard/widgets/view_model/compost_progress/compost_batch_model.dart';

class BatchCompleteDialog extends StatefulWidget {
  final CompostBatch batch;
  final VoidCallback? onComplete;

  const BatchCompleteDialog({required this.batch, this.onComplete, super.key});

  @override
  State<BatchCompleteDialog> createState() => _BatchCompleteDialogState();
}

class _BatchCompleteDialogState extends State<BatchCompleteDialog> {
  final _finalWeightController = TextEditingController();
  final _completionNotesController = TextEditingController();

  String? _weightError;

  @override
  void dispose() {
    _finalWeightController.dispose();
    _completionNotesController.dispose();
    super.dispose();
  }

  String? _validateWeight(String? value) {
    if (value == null || value.isEmpty) {
      return 'Final weight is required';
    }
    final weight = double.tryParse(value);
    if (weight == null) {
      return 'Enter a valid number';
    }
    if (weight <= 0) {
      return 'Weight must be greater than 0';
    }
    return null;
  }

  void _handleComplete() {
    final weightError = _validateWeight(_finalWeightController.text);

    if (weightError != null) {
      setState(() => _weightError = weightError);
      return;
    }

    // Update batch with completion data
    final updatedBatch = widget.batch.copyWith(
      status: 'completed',
      completedAt: DateTime.now(),
      finalWeight: double.parse(_finalWeightController.text),
      completionNotes: _completionNotesController.text.trim().isEmpty
          ? null
          : _completionNotesController.text.trim(),
    );

    Navigator.of(context).pop(updatedBatch);
    if (widget.onComplete != null) widget.onComplete!();
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    final monthNames = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${monthNames[date.month - 1]} ${date.day}, ${date.year}';
  }

  int _getDaysPassed() {
    final now = DateTime.now();
    return now.difference(widget.batch.batchStart).inDays;
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_getDaysPassed() / 12).clamp(0.0, 1.0);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(25),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.compost, color: Colors.teal[700]),
                      const SizedBox(width: 8),
                      Text(
                        'Batch Details',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Progress Bar Section (at top)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.teal.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.teal.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Decomposition Progress',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Colors.teal.shade900,
                          ),
                        ),
                        Text(
                          '${(progress * 100).toInt()}%',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.white,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.teal.shade600,
                        ),
                        minHeight: 10,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Day ${_getDaysPassed()} of 12',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.teal.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Batch Information Card
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Batch Information',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow('Batch Name', widget.batch.batchName),
                    _buildDetailRow('Batch Number', widget.batch.batchNumber),
                    _buildDetailRow(
                      'Started By',
                      widget.batch.startedBy ?? 'null',
                    ),
                    _buildDetailRow(
                      'Start Date',
                      _formatDate(widget.batch.batchStart),
                    ),
                    if (widget.batch.startNotes != null)
                      _buildDetailRow('Start Notes', widget.batch.startNotes!),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Final Weight Field
              Text(
                'Final Weight (kg)',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _finalWeightController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                ],
                decoration: InputDecoration(
                  hintText: 'Enter final weight',
                  prefixIcon: Icon(Icons.scale, color: Colors.teal[600]),
                  suffixText: 'kg',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  errorText: _weightError,
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: Colors.teal.shade600,
                      width: 2,
                    ),
                  ),
                ),
                onChanged: (value) {
                  if (_weightError != null) {
                    setState(() => _weightError = null);
                  }
                },
              ),
              const SizedBox(height: 16),

              // Completion Notes Field
              Text(
                'Completion Notes (Optional)',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _completionNotesController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Quality, observations, issues...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: Colors.teal.shade600,
                      width: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Cancel',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _handleComplete,
                    icon: const Icon(Icons.check_circle, size: 18),
                    label: const Text('Complete Batch'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal[700],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label:',
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.black54,
              fontSize: 13,
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
                fontSize: 13,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
