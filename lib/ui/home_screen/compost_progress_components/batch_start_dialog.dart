// lib/ui/home_screen/compost_progress_components/batch_start_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_1/data/providers/batch_providers.dart';

import 'package:firebase_auth/firebase_auth.dart';

class BatchStartDialog extends ConsumerStatefulWidget {
  final String? preSelectedMachineId;

  const BatchStartDialog({super.key, this.preSelectedMachineId});

  @override
  ConsumerState<BatchStartDialog> createState() => _BatchStartDialogState();
}

class _BatchStartDialogState extends ConsumerState<BatchStartDialog> {
  final _batchNameController = TextEditingController();
  final _startNotesController = TextEditingController();
  String? _selectedMachineId;
  String? _nameError;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedMachineId = widget.preSelectedMachineId;
  }

  @override
  void dispose() {
    _batchNameController.dispose();
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

  Future<void> _handleConfirm() async {
    final nameError = _validateBatchName(_batchNameController.text);

    if (nameError != null) {
      setState(() => _nameError = nameError);
      return;
    }

    if (_selectedMachineId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a machine')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) throw Exception('User not logged in');

      final batchRepo = ref.read(batchRepositoryProvider);
      
      // Get existing active batch ID or create new one
      String? batchId = await batchRepo.getBatchId(userId, _selectedMachineId!);
      
      if (batchId == null) {
        // Generate batch number (you can implement counter logic later)
        final batchNumber = DateTime.now().millisecondsSinceEpoch % 1000000;
        batchId = await batchRepo.createBatch(userId, _selectedMachineId!, batchNumber);
      } else {
        // Update existing batch timestamp
        await batchRepo.updateBatchTimestamp(batchId);
      }

      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Batch started successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      
      Navigator.of(context).pop(true); // Return success

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to start batch: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
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

              // Machine Selection (if not pre-selected)
              if (widget.preSelectedMachineId == null) ...[
                Text(
                  'Select Machine',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 8),
                // Add machine dropdown here (you can reuse MachineSelectionField)
                const SizedBox(height: 16),
              ],

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
                enabled: !_isLoading,
                decoration: InputDecoration(
                  hintText: 'e.g., October Vegetable Waste',
                  prefixIcon: Icon(Icons.label_outline, color: Colors.teal[600]),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
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
                enabled: !_isLoading,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Add any observations or notes...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
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
                    onPressed: _isLoading ? null : () => Navigator.pop(context),
                    child: Text('Cancel', style: TextStyle(color: Colors.grey[600])),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _isLoading ? null : _handleConfirm,
                    icon: _isLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Icon(Icons.play_arrow, size: 18),
                    label: Text(_isLoading ? 'Starting...' : 'Start Batch'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal[700],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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