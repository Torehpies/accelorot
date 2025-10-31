// lib/frontend/operator/dashboard/compost_progress/components/batch_id_dialog.dart
import 'package:flutter/material.dart';

class BatchIdDialog extends StatefulWidget {
  const BatchIdDialog({super.key});

  @override
  State<BatchIdDialog> createState() => _BatchIdDialogState();
}

class _BatchIdDialogState extends State<BatchIdDialog> {
  final _batchIdController = TextEditingController();
  String? _errorText;

  @override
  void dispose() {
    _batchIdController.dispose();
    super.dispose();
  }

  String? _validateBatchId(String? value) {
    if (value == null || value.isEmpty) {
      return 'Batch ID is required';
    }
    if (value.length < 3) {
      return 'Batch ID must be at least 3 characters';
    }
    return null;
  }

  void _handleConfirm() {
    final error = _validateBatchId(_batchIdController.text);
    if (error != null) {
      setState(() => _errorText = error);
      return;
    }
    Navigator.of(context).pop(_batchIdController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
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
                    Icon(Icons.label_outline, color: Colors.green.shade700, size: 22),
                    const SizedBox(width: 8),
                    Text(
                      'Start Batch',
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

            // Batch ID input field
            Text(
              'Batch ID',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _batchIdController,
              decoration: InputDecoration(
                hintText: 'e.g., BATCH-001',
                prefixIcon: Icon(Icons.tag, color: Colors.green.shade600),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                errorText: _errorText,
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.green.shade600, width: 2),
                ),
              ),
              onChanged: (value) {
                if (_errorText != null) {
                  setState(() => _errorText = null);
                }
              },
              onSubmitted: (_) => _handleConfirm(),
            ),
            const SizedBox(height: 24),

            // Action buttons
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
                  onPressed: _handleConfirm,
                  icon: const Icon(Icons.check, size: 18),
                  label: const Text('Start Batch'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade700,
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
    );
  }
}
