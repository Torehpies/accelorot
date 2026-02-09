// lib/ui/operator_dashboard/fields/batch_selection_field.dart

import 'package:flutter/material.dart';
import '../../core/widgets/bottom_sheets/fields/mobile_dropdown_field.dart';
import '../../core/skeleton/skeleton_dropdown.dart';
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
    _repository = BatchRepositoryRemote(
      FirestoreBatchService(FirebaseFirestore.instance),
    );
  }

  /// Fetch active batches for the selected machine
  Future<List<BatchModel>> _fetchMachineBatches() async {
    if (widget.selectedMachineId == null || widget.selectedMachineId!.isEmpty) {
      return [];
    }

    try {
      final batches = await _repository.getBatchesForMachines([
        widget.selectedMachineId!,
      ]);
      // Filter for active batches and sort by creation date (newest first)
      return batches.where((batch) => batch.isActive).toList()
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
        // Show skeleton loader while loading (only if machine is selected)
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Only show skeleton if we're actually loading data (machine selected)
          if (widget.selectedMachineId != null && 
              widget.selectedMachineId!.isNotEmpty) {
            return const SkeletonDropdown(
              label: 'Batch',
              showRequired: false,
            );
          }
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
        if (widget.selectedMachineId == null ||
            widget.selectedMachineId!.isEmpty) {
          return MobileDropdownField<String>(
            label: 'Batch',
            value: null,
            items: const [
              MobileDropdownItem(value: '', label: 'Select machine first'),
            ],
            enabled: false,
            hintText: 'Select a machine first',
            helperText: 'Choose a machine to see available batches',
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

        // Convert batches to dropdown items
        final items = batches.map((batch) {
          return MobileDropdownItem<String>(
            value: batch.id,
            label: batch.displayName,
          );
        }).toList();

        return MobileDropdownField<String>(
          label: 'Batch',
          value: widget.selectedBatchId,
          items: items,
          enabled: !widget.isLocked,
          onChanged: widget.isLocked ? null : widget.onChanged,
          errorText: widget.errorText,
          hintText: 'Select batch',
          helperText: widget.isLocked ? 'Batch is locked for this context' : null,
        );
      },
    );
  }
}