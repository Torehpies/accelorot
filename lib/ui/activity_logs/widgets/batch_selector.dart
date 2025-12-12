import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/providers/batch_providers.dart';

/// Reusable batch selector dropdown
class BatchSelector extends ConsumerWidget {
  final String? selectedBatchId;
  final String? selectedMachineId;
  final ValueChanged<String?> onChanged;
  final bool isCompact;
  final bool showLabel;

  const BatchSelector({
    super.key,
    required this.selectedBatchId,
    required this.onChanged,
    this.selectedMachineId,
    this.isCompact = false,
    this.showLabel = true,
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

        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: isCompact ? 8 : 12,
            vertical: isCompact ? 6 : 8,
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
                  value: selectedBatchId,
                  hint: Text(
                    'All Batches',
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
                  disabledHint: Text(
                    selectedMachineId != null
                        ? 'No batches for this machine'
                        : 'No batches available',
                    style: TextStyle(
                      fontSize: isCompact ? 13 : 14,
                      color: Colors.grey[400],
                    ),
                  ),
                  items: hasNoBatches
                      ? null
                      : [
                          const DropdownMenuItem<String>(
                            value: null,
                            child: Text('All Batches'),
                          ),
                          ...filteredBatches.map((batch) {
                            return DropdownMenuItem<String>(
                              value: batch.id,
                              child: Text(
                                batch.id,
                                style: TextStyle(fontSize: isCompact ? 13 : 14),
                              ),
                            );
                          }),
                        ],
                  onChanged: hasNoBatches ? null : onChanged,
                ),
              ),
            ],
          ),
        );
      },
      loading: () => Container(
        padding: EdgeInsets.symmetric(
          horizontal: isCompact ? 8 : 12,
          vertical: isCompact ? 6 : 8,
        ),
        decoration: BoxDecoration(
          color: isCompact ? Colors.grey[50] : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
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
                'Loading batches...',
                style: TextStyle(
                  fontSize: isCompact ? 13 : 14,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      ),
      error: (_, _) => const SizedBox.shrink(),
    );
  }
}