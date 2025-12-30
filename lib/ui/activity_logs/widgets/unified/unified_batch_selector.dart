// lib/ui/activity_logs/widgets/unified/unified_batch_selector.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/providers/batch_providers.dart';
import 'unified_dropdown.dart';

class UnifiedBatchSelector extends ConsumerWidget {
  final String? selectedBatchId;
  final String? selectedMachineId;
  final ValueChanged<String?> onChanged;

  const UnifiedBatchSelector({
    super.key,
    required this.selectedBatchId,
    required this.onChanged,
    this.selectedMachineId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final batchesAsync = ref.watch(userTeamBatchesProvider);

    return batchesAsync.when(
      data: (batches) {
        final filteredBatches = selectedMachineId != null
            ? batches.where((b) => b.machineId == selectedMachineId).toList()
            : batches;

        final hasNoBatches = filteredBatches.isEmpty;
        
        return UnifiedDropdown<String>(
          value: selectedBatchId,
          label: 'Batch',
          hintText: 'All Batches',
          displayText: selectedBatchId ?? 'All Batches',
          icon: Icons.inventory_2,
          onChanged: hasNoBatches ? (_) {} : onChanged,
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
      loading: () => UnifiedDropdown<String>(
        value: null,
        label: 'Batch',
        hintText: 'All Batches',
        items: const [],
        onChanged: (_) {},
        icon: Icons.inventory_2,
        isLoading: true,
      ),
      error: (_, _) => UnifiedDropdown<String>(
        value: null,
        label: 'Batch',
        hintText: 'All Batches',
        items: const [],
        onChanged: (_) {},
        icon: Icons.inventory_2,
        disabledHint: 'Error loading',
      ),
    );
  }
}
