// lib/ui/activity_logs/widgets/mobile/batch_selector.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/providers/batch_providers.dart';
import '../../../core/widgets/filters/mobile_selector_button.dart';

/// Reusable batch selector dropdown
class BatchSelector extends ConsumerWidget {
  final String? selectedBatchId;
  final String? selectedMachineId;
  final ValueChanged<String?> onChanged;
  final ValueChanged<String?>? onMachineAutoSelect;
  final bool isCompact;
  final bool showLabel;
  final bool showAllOption;
  final bool showOnlyActive;

  const BatchSelector({
    super.key,
    required this.selectedBatchId,
    required this.onChanged,
    this.selectedMachineId,
    this.onMachineAutoSelect,
    this.isCompact = false,
    this.showLabel = true,
    this.showAllOption = true,
    this.showOnlyActive = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final batchesAsync = ref.watch(userTeamBatchesProvider);

    return batchesAsync.when(
      data: (batches) {
        // Filter by machine if selected
        var filteredBatches = selectedMachineId != null
            ? batches
                .where((b) => b.machineId == selectedMachineId)
                .toList()
            : batches;

        // Filter by active status if needed
        if (showOnlyActive) {
          filteredBatches = filteredBatches.where((b) => b.isActive).toList();
        } else {
          // If showing both, separate active and completed
          final activeBatches =
              filteredBatches.where((b) => b.isActive).toList();
          final completedBatches =
              filteredBatches.where((b) => !b.isActive).toList();
          activeBatches.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          completedBatches.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          filteredBatches = [...activeBatches, ...completedBatches];
        }

        // Sort by creation date if showing only active
        if (showOnlyActive) {
          filteredBatches.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        }

        return MobileSelectorButton(
          icon: Icons.inventory_2,
          allLabel: 'All Batches',
          selectedItemId: selectedBatchId,
          items: filteredBatches,
          itemId: (b) => b.id,
          displayName: (b) => b.displayName,
          statusBadge: (b) => !b.isActive ? 'Completed' : null,
          onChanged: (batchId) {
            // Auto-select machine when batch is selected
            if (batchId != null && onMachineAutoSelect != null) {
              final selectedBatch = filteredBatches.firstWhere(
                (b) => b.id == batchId,
              );
              onMachineAutoSelect!(selectedBatch.machineId);
            } else if (batchId == null && onMachineAutoSelect != null) {
              // Reset machine when "All Batches" selected
              onMachineAutoSelect!(null);
            }
            // Then call the batch changed callback
            onChanged(batchId);
          },
          emptyMessage: selectedMachineId != null
              ? 'No batches for machine'
              : 'No batches',
        );
      },
      loading: () => MobileSelectorButton<dynamic>(
        icon: Icons.inventory_2,
        allLabel: 'All Batches',
        selectedItemId: null,
        items: const [],
        itemId: (_) => '',
        displayName: (_) => '',
        onChanged: (_) {},
        isLoading: true,
      ),
      error: (_, __) => MobileSelectorButton<dynamic>(
        icon: Icons.inventory_2,
        allLabel: 'All Batches',
        selectedItemId: null,
        items: const [],
        itemId: (_) => '',
        displayName: (_) => '',
        onChanged: (_) {},
        emptyMessage: 'Error loading',
      ),
    );
  }
}