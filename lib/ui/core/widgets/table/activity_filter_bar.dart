// lib/ui/core/widgets/table/activity_filter_bar.dart

import 'package:flutter/material.dart';
import '../../../activity_logs/widgets/unified/unified_machine_selector.dart';
import '../../../activity_logs/widgets/unified/unified_batch_selector.dart';
import '../../../activity_logs/widgets/date_filter_dropdown.dart';
import '../../../activity_logs/models/activity_common.dart';
import '../../themes/web_text_styles.dart';

/// Filter bar for activity logs with Machine, Batch, Date, and Search filters
class ActivityFilterBar extends StatelessWidget {
  final String? selectedMachineId;
  final String? selectedBatchId;
  final DateFilterRange dateFilter;
  final String searchQuery;
  final ValueChanged<String?> onMachineChanged;
  final ValueChanged<String?> onBatchChanged;
  final ValueChanged<DateFilterRange> onDateFilterChanged;
  final ValueChanged<String> onSearchChanged;

  const ActivityFilterBar({
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
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Left Group: Machine and Batch
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 150, maxWidth: 220),
            child: SizedBox(
              height: 32,
              child: UnifiedMachineSelector(
                selectedMachineId: selectedMachineId,
                onChanged: onMachineChanged,
              ),
            ),
          ),
          const SizedBox(width: 12),
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 150, maxWidth: 220),
            child: SizedBox(
              height: 32,
              child: UnifiedBatchSelector(
                selectedBatchId: selectedBatchId,
                selectedMachineId: selectedMachineId,
                onChanged: onBatchChanged,
              ),
            ),
          ),
          
          const Spacer(), // Create space in the middle
          
          // Right Group: Date and Search (swapped order)
          SizedBox(
            height: 32,
            child: DateFilterDropdown(
              onFilterChanged: onDateFilterChanged,
            ),
          ),
          const SizedBox(width: 12),
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 150, maxWidth: 220),
            child: Container(
              height: 32,
              padding: const EdgeInsets.symmetric(horizontal: 12),
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
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      onChanged: onSearchChanged,
                      decoration: const InputDecoration(
                        hintText: 'Search...',
                        hintStyle: WebTextStyles.bodyMediumGray,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                        isDense: true,
                      ),
                      style: WebTextStyles.bodyMedium,
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
