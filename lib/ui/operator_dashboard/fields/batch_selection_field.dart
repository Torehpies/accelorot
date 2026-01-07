import 'package:flutter/material.dart';
import '../../../data/models/batch_model.dart';
import '../../../data/services/firebase/firebase_batch_service.dart'; 
import '../../../data/repositories/batch_repository/batch_repository.dart'; 
import '../../../data/repositories/batch_repository/batch_repository_remote.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

class BatchSelectionField extends StatefulWidget {
  final String? selectedBatchId;
  final String? selectedMachineId;
  final Function(String?)? onChanged;
  final bool isLocked;
  final String? errorText;

  const BatchSelectionField({
    super.key,
    required this.selectedBatchId,
    required this.selectedMachineId,
    this.onChanged,
    this.isLocked = false,
    this.errorText,
  });

  @override
  State<BatchSelectionField> createState() => _BatchSelectionFieldState();
}

class _BatchSelectionFieldState extends State<BatchSelectionField> {
  late final BatchRepository _repository;

  @override
  void initState() {
    super.initState();
    _repository = BatchRepositoryRemote(FirestoreBatchService(FirebaseFirestore.instance)); // ✅ FIXED: Added FirebaseFirestore.instance
  }

  /// Fetch active batches for the selected machine
  Future<List<BatchModel>> _fetchMachineBatches() async {
    if (widget.selectedMachineId == null || widget.selectedMachineId!.isEmpty) {
      return [];
    }

    try {
      final batches = await _repository.getBatchesForMachines([widget.selectedMachineId!]);
      // Filter for active batches and sort by creation date (newest first)
      return batches
          .where((batch) => batch.isActive)
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      throw Exception('Failed to fetch batches: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<BatchModel>>(
      future: _fetchMachineBatches(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Error loading batches: ${snapshot.error}',
                    style: TextStyle(color: Colors.red.shade700, fontSize: 12),
                  ),
                ),
              ],
            ),
          );
        }

        final batches = snapshot.data ?? [];
        
        // If no machine selected, show disabled state
        if (widget.selectedMachineId == null || widget.selectedMachineId!.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                Icon(Icons.inventory_2, color: Colors.grey.shade500, size: 20),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Select a machine first',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        // If no batches available
        if (batches.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.orange.shade700,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'No active batches for this machine. Start a batch first.',
                    style: TextStyle(
                      color: Colors.orange,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return DropdownButtonFormField<String>(
          initialValue: widget.selectedBatchId,
          decoration: InputDecoration(
            labelText: 'Select Batch',
            prefixIcon: const Icon(Icons.inventory_2, size: 18),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            suffixIcon: widget.isLocked
                ? const Icon(Icons.lock, size: 18, color: Colors.grey)
                : null,
            errorText: widget.errorText,
          ),
          items: batches.map((batch) {
            return DropdownMenuItem<String>(
              value: batch.id,
              enabled: !widget.isLocked,
              child: Text(
                batch.displayName,
                style: TextStyle(
                  color: widget.isLocked ? Colors.grey : Colors.black87,
                ),
              ),
            );
          }).toList(),
          onChanged: widget.isLocked ? null : widget.onChanged,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select a batch';
            }
            return null;
          },
        );
      },
    );
  }
}