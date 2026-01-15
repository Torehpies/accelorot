// lib/ui/activity_logs/widgets/unified/web_batch_selector.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/providers/batch_providers.dart';
import 'web_dropdown.dart';
import 'web_table_container.dart';

class WebBatchSelector extends ConsumerWidget {
  final String? selectedBatchId;
  final String? selectedMachineId;
  final ValueChanged<String?> onChanged;
  final DropdownDisplayMode displayMode;

  const WebBatchSelector({
    super.key,
    required this.selectedBatchId,
    required this.onChanged,
    this.selectedMachineId,
    required this.displayMode,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final batchesAsync = ref.watch(userTeamBatchesProvider);

    return batchesAsync.when(
      data: (batches) {
        // Filter batches by selected machine if applicable
        final filteredBatches = selectedMachineId != null
            ? batches.where((b) => b.machineId == selectedMachineId).toList()
            : batches;
        
        final hasNoBatches = filteredBatches.isEmpty;

        // Look up the selected batch to get its proper display name
        final selectedBatch = selectedBatchId != null && filteredBatches.any((b) => b.id == selectedBatchId)
            ? filteredBatches.firstWhere((b) => b.id == selectedBatchId)
            : null;

        return WebDropdown<String>(
          value: selectedBatchId,
          label: 'Batch',
          hintText: 'All Batches',
          // Show batch ID if selected, otherwise "All Batches"
          displayText: selectedBatch?.id ?? 'All Batches',
          icon: Icons.inventory_2,
          onChanged: hasNoBatches ? (_) {} : onChanged,
          displayMode: displayMode,
          items: hasNoBatches
              ? const []
              : [
                  const PopupMenuItem<String>(
                    value: null,
                    child: Text('All Batches'),
                  ),
                  ...filteredBatches.map((batch) {
                    return PopupMenuItem<String>(
                      value: batch.id,
                      child: Text(batch.id),
                    );
                  }),
                ],
          disabledHint: selectedMachineId != null && hasNoBatches
              ? 'No batches for machine'
              : (hasNoBatches ? 'No batches' : null),
        );
      },
      loading: () => WebDropdown<String>(
        value: null,
        label: 'Batch',
        hintText: 'All Batches',
        items: const [],
        onChanged: (_) {},
        icon: Icons.inventory_2,
        isLoading: true,
        displayMode: displayMode,
      ),
      error: (_, __) => WebDropdown<String>(
        value: null,
        label: 'Batch',
        hintText: 'All Batches',
        items: const [],
        onChanged: (_) {},
        icon: Icons.inventory_2,
        disabledHint: 'Error loading',
        displayMode: displayMode,
      ),
    );
  }
}