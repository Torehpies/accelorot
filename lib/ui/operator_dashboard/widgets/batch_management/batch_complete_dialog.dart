// lib/frontend/operator/dashboard/compost_progress/components/batch_complete_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../view_model/compost_progress/compost_batch_model.dart';
import '../../../../data/providers/batch_providers.dart';


class BatchCompleteDialog extends ConsumerStatefulWidget {
  final CompostBatch batch;
  final VoidCallback? onComplete;

  const BatchCompleteDialog({required this.batch, this.onComplete, super.key});

  @override
  ConsumerState<BatchCompleteDialog> createState() => _BatchCompleteDialogState();
}

class _BatchCompleteDialogState extends ConsumerState<BatchCompleteDialog> {
  final _finalWeightController = TextEditingController();
  final _completionNotesController = TextEditingController();

  String? _weightError;
  bool _isLoading = false;

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
      return 'Please enter a valid number';
    }
    if (weight <= 0) {
      return 'Weight must be greater than 0';
    }
    return null;
  }

  Future<void> _handleComplete() async {
    final weightError = _validateWeight(_finalWeightController.text);

    if (weightError != null) {
      setState(() => _weightError = weightError);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final finalWeight = double.parse(_finalWeightController.text);
      final completionNotes = _completionNotesController.text.trim();

      // Get batch repository
      final batchRepo = ref.read(batchRepositoryProvider);

      // Complete the batch in Firestore
      await batchRepo.completeBatch(
        widget.batch.batchNumber, // This is actually the batchId
        finalWeight: finalWeight,
        completionNotes: completionNotes.isEmpty ? null : completionNotes,
      );

      if (!mounted) return;

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Batch completed successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // Callback and close
      widget.onComplete?.call();
      Navigator.of(context).pop(true);

    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to complete batch: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return '${date.month}/${date.day}/${date.year}';
  }

  int _getDaysPassed() {
    final now = DateTime.now();
    return now.difference(widget.batch.batchStart).inDays;
  }

  @override
  Widget build(BuildContext context) {
    final daysPassed = _getDaysPassed();

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(50),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Complete Batch',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Batch details
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    _buildDetailRow('Batch Name', widget.batch.batchName),
                    const SizedBox(height: 8),
                    _buildDetailRow('Batch ID', widget.batch.batchNumber),
                    const SizedBox(height: 8),
                    _buildDetailRow('Started', _formatDate(widget.batch.batchStart)),
                    const SizedBox(height: 8),
                    _buildDetailRow('Days Elapsed', '$daysPassed days'),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Final weight input
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
                enabled: !_isLoading,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                decoration: InputDecoration(
                  hintText: 'Enter weight in kg',
                  prefixIcon: const Icon(Icons.scale),
                  errorText: _weightError,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.teal, width: 2),
                  ),
                ),
                onChanged: (value) {
                  if (_weightError != null) {
                    setState(() => _weightError = null);
                  }
                },
              ),
              const SizedBox(height: 16),

              // Completion notes
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
                enabled: !_isLoading,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Add any final observations...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.teal, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _handleComplete,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text('Complete Batch'),
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}