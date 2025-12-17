// lib/ui/activity_logs/widgets/unified/filter_bar_row.dart

import 'package:flutter/material.dart';
import '../../widgets/machine_selector.dart';
import '../../widgets/batch_selector.dart';
import '../../widgets/date_filter_button.dart';
import '../../models/activity_common.dart';

/// Filter bar with Machine, Batch, Date, and Search
class FilterBarRow extends StatelessWidget {
  final String? selectedMachineId;
  final String? selectedBatchId;
  final DateFilterRange dateFilter;
  final String searchQuery;
  final ValueChanged<String?> onMachineChanged;
  final ValueChanged<String?> onBatchChanged;
  final ValueChanged<DateFilterRange> onDateFilterChanged;
  final ValueChanged<String> onSearchChanged;

  const FilterBarRow({
    super.key,
    required this.selectedMachineId,
    required this.selectedBatchId,
    required this.dateFilter,
    required this.searchQuery,
    required this.onMachineChanged,
    required this.onBatchChanged,
    required this.onDateFilterChanged,
    required this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          // Machine Selector
          Expanded(
            flex: 2,
            child: SizedBox(
              height: 44,
              child: MachineSelector(
                selectedMachineId: selectedMachineId,
                onChanged: onMachineChanged,
                isCompact: true,
              ),
            ),
          ),
          const SizedBox(width: 16),
          
          // Batch Selector
          Expanded(
            flex: 2,
            child: SizedBox(
              height: 44,
              child: BatchSelector(
                selectedBatchId: selectedBatchId,
                selectedMachineId: selectedMachineId,
                onChanged: onBatchChanged,
                isCompact: true,
                showLabel: false,
              ),
            ),
          ),
          const SizedBox(width: 16),
          
          // Date Filter Button
          SizedBox(
            height: 44,
            child: DateFilterButton(
              onFilterChanged: onDateFilterChanged,
            ),
          ),
          const SizedBox(width: 16),
          
          // Search Bar
          Expanded(
            flex: 3,
            child: Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.search,
                    color: Color(0xFF6B7280),
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      onChanged: onSearchChanged,
                      decoration: const InputDecoration(
                        hintText: 'Search...',
                        hintStyle: TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF6B7280),
                        ),
                        border: InputBorder.none,
                      ),
                      style: const TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF374151),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}