import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/providers/batch_providers.dart';
import '../../../../data/models/batch_model.dart';

/// Reusable batch selector dropdown
class BatchSelector extends ConsumerWidget {
  final String? selectedBatchId;
  final String? selectedMachineId;
  final ValueChanged<String?> onChanged;
  final ValueChanged<String?>? onMachineAutoSelect;
  final bool isCompact;
  final bool showLabel;
  final bool showAllOption;
  final bool showOnlyActive; // New parameter to filter batches

  const BatchSelector({
    super.key,
    required this.selectedBatchId,
    required this.onChanged,
    this.selectedMachineId,
    this.onMachineAutoSelect,
    this.isCompact = false,
    this.showLabel = true,
    this.showAllOption = true,
    this.showOnlyActive = true, // Default: show only active batches
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the AsyncNotifierProvider properly
    final batchesAsync = ref.watch(userTeamBatchesProvider);

    // Use .when but checks value first to avoid loading flickering
    final batches = batchesAsync.value;
    final isLoading = batchesAsync.isLoading && !batchesAsync.hasValue;

    if (isLoading) {
      // Loading state - only if we have NO data
      return Container(
        padding: EdgeInsets.symmetric(
          horizontal: isCompact ? 8 : 12,
          vertical: isCompact ? 4 : 8,
        ),
        decoration: BoxDecoration(
          color: isCompact ? Colors.grey[50] : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: isCompact
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          children: [
            Icon(
              Icons.inventory_2,
              color: Colors.grey[400],
              size: isCompact ? 18 : 20,
            ),
            const SizedBox(width: 12),
            if (showLabel) ...[
              Text(
                'Batch:',
                style: TextStyle(
                  fontSize: isCompact ? 13 : 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Text(
                showAllOption ? 'All Batches' : 'Select Batch',
                style: TextStyle(
                  fontSize: isCompact ? 13 : 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[400],
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (batchesAsync.hasError && !batchesAsync.hasValue) {
      return Container(
        padding: EdgeInsets.symmetric(
          horizontal: isCompact ? 8 : 12,
          vertical: isCompact ? 6 : 8,
        ),
        decoration: BoxDecoration(
          color: isCompact ? Colors.grey[50] : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.red.shade200),
        ),
        child: Row(
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.red[400],
              size: isCompact ? 18 : 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Failed to load batches',
                style: TextStyle(
                  fontSize: isCompact ? 13 : 14,
                  color: Colors.red[600],
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Render with data (or empty list if null but not loading)
    final safeBatches = batches ?? [];
    return _buildDropdown(safeBatches);
  }

  Widget _buildDropdown(List<BatchModel> batches) {
    // Filter by machine if specified
    var filteredBatches = selectedMachineId != null
        ? batches.where((b) => b.machineId == selectedMachineId).toList()
        : batches;

    // Filter by active status if needed
    if (showOnlyActive) {
      filteredBatches = filteredBatches.where((b) => b.isActive).toList();
    } else {
      // If showing both, separate active and completed, then combine with active first
      final activeBatches = filteredBatches.where((b) => b.isActive).toList();
      final completedBatches = filteredBatches
          .where((b) => !b.isActive)
          .toList();
      activeBatches.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      completedBatches.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      filteredBatches = [...activeBatches, ...completedBatches];
    }

    // Sort by creation date if showing only active
    if (showOnlyActive) {
      filteredBatches.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }

    final hasNoBatches = filteredBatches.isEmpty;

    // Ensure selectedBatchId is in the list
    final safeSelectedBatchId =
        filteredBatches.any((b) => b.id == selectedBatchId)
        ? selectedBatchId
        : null;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 8 : 12,
        vertical: isCompact ? 4 : 8,
      ),
      decoration: BoxDecoration(
        color: isCompact ? Colors.grey[50] : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: isCompact
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.inventory_2,
            color: hasNoBatches
                ? Colors.grey[400]
                : (isCompact ? Colors.teal.shade700 : Colors.grey[700]),
            size: isCompact ? 18 : 20,
          ),
          const SizedBox(width: 12),
          if (showLabel) ...[
            Text(
              'Batch:',
              style: TextStyle(
                fontSize: isCompact ? 13 : 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: DropdownButton<String>(
              value: safeSelectedBatchId,
              hint: Text(
                hasNoBatches
                    ? (selectedMachineId != null
                          ? 'No batches'
                          : 'No batches available')
                    : (showAllOption ? 'All Batches' : 'Select Batch'),
                style: TextStyle(
                  fontSize: isCompact ? 13 : 14,
                  fontWeight: FontWeight.w600,
                  color: hasNoBatches ? Colors.grey[400] : null,
                ),
              ),
              isExpanded: true,
              underline: const SizedBox(),
              icon: Icon(
                Icons.arrow_drop_down,
                color: hasNoBatches
                    ? Colors.grey[400]
                    : (isCompact ? Colors.teal.shade700 : Colors.teal),
              ),
              menuMaxHeight: 400,
              items: hasNoBatches
                  ? null
                  : [
                      // Only show "All Batches" if showAllOption is true
                      if (showAllOption)
                        const DropdownMenuItem<String>(
                          value: null,
                          child: Text('All Batches'),
                        ),
                      ...filteredBatches.map((batch) {
                        return DropdownMenuItem<String>(
                          value: batch.id,
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  batch.displayName,
                                  style: TextStyle(
                                    fontSize: isCompact ? 13 : 14,
                                  ),
                                ),
                              ),
                              if (!batch.isActive)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    'Completed',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey.shade600,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      }),
                    ],
              onChanged: hasNoBatches
                  ? null
                  : (batchId) {
                      // Auto-select machine FIRST when batch is selected
                      if (batchId != null && onMachineAutoSelect != null) {
                        final selectedBatch = filteredBatches.firstWhere(
                          (b) => b.id == batchId,
                        );
                        onMachineAutoSelect!(selectedBatch.machineId);
                      } else if (batchId == null &&
                          onMachineAutoSelect != null) {
                        // Reset machine selection when "All Batches" is selected
                        onMachineAutoSelect!(null);
                      }
                      // Then call the batch changed callback
                      onChanged(batchId);
                    },
            ),
          ),
        ],
      ),
    );
  }
}
