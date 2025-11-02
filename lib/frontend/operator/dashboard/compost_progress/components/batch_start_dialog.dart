// lib/frontend/operator/dashboard/compost_progress/components/batch_start_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/compost_batch_model.dart';

class BatchStartDialog extends StatefulWidget {
  const BatchStartDialog({super.key});

  @override
  State<BatchStartDialog> createState() => _BatchStartDialogState();
}

class _BatchStartDialogState extends State<BatchStartDialog> {
  final _batchNameController = TextEditingController();
  final _batchNumberController = TextEditingController();
  final _startNotesController = TextEditingController();
  
  String? _nameError;
  String? _numberError;

  @override
  void dispose() {
    _batchNameController.dispose();
    _batchNumberController.dispose();
    _startNotesController.dispose();
    super.dispose();
  }

  String? _validateBatchName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Batch name is required';
    }
    if (value.length < 3) {
      return 'Name must be at least 3 characters';
    }
    return null;
  }

  String? _validateBatchNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Batch number is required';
    }
    if (value.length > 6) {
      return 'Maximum 6 digits';
    }
    if (!RegExp(r'^\d+$').hasMatch(value)) {
      return 'Only numbers allowed';
    }
    return null;
  }

  void _handleConfirm() {
    final nameError = _validateBatchName(_batchNameController.text);
    final numberError = _validateBatchNumber(_batchNumberController.text);
    
    if (nameError != null || numberError != null) {
      setState(() {
        _nameError = nameError;
        _numberError = numberError;
      });
      return;
    }

    // Create batch object
    final batch = CompostBatch(
      batchName: _batchNameController.text.trim(),
      batchNumber: 'Batch-${_batchNumberController.text.trim()}',
      batchStart: DateTime.now(),
      startNotes: _startNotesController.text.trim().isEmpty 
          ? null 
          : _startNotesController.text.trim(),
    );

    Navigator.of(context).pop(batch);
  }

  @override
  Widget build(BuildContext context) {
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
                  Text(
                    'Composting Batch',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
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

              // Batch Name Field
              Text(
                'Batch Name',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _batchNameController,
                decoration: InputDecoration(
                  hintText: 'e.g., October Vegetable Waste',
                  prefixIcon: Icon(Icons.label_outline, color: Colors.teal[600]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  errorText: _nameError,
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.teal.shade600, width: 2),
                  ),
                ),
                onChanged: (value) {
                  if (_nameError != null) {
                    setState(() => _nameError = null);
                  }
                },
              ),
              const SizedBox(height: 16),

              // Batch Number Field
              Text(
                'Batch Number',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _batchNumberController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(6),
                ],
                decoration: InputDecoration(
                  hintText: 'Up to 6 digits',
                  prefixIcon: Icon(Icons.tag, color: Colors.teal[600]),
                  prefix: Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Text(
                      'Batch-',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  errorText: _numberError,
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.teal.shade600, width: 2),
                  ),
                ),
                onChanged: (value) {
                  if (_numberError != null) {
                    setState(() => _numberError = null);
                  }
                },
              ),
              const SizedBox(height: 16),

              // Start Notes Field
              Text(
                'Start Notes (Optional)',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _startNotesController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Add any observations or notes...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.teal.shade600, width: 2),
                  ),
                ),
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
                    icon: const Icon(Icons.play_arrow, size: 18),
                    label: const Text('Start Batch'),
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
}