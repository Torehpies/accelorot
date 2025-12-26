// lib/ui/activity_logs/widgets/unified/unified_table_container.dart

import 'package:flutter/material.dart';
import '../../../../data/models/activity_log_item.dart';
import '../../models/activity_common.dart';
import '../../../core/widgets/shared/pagination_controls.dart';
import '../../../core/widgets/table/base_table_container.dart';
import '../../../core/widgets/filters/search_field.dart';
import '../../../core/widgets/table/activity_table_header.dart';
import '../../../core/widgets/table/activity_table_body.dart';
import 'unified_machine_selector.dart';
import 'unified_batch_selector.dart';
import '../../../core/widgets/filters/date_filter_dropdown.dart';

/// Unified container for activity logs using BaseTableContainer
class UnifiedTableContainer extends StatelessWidget {
  final List<ActivityLogItem> items;
  final bool isLoading; // NEW: Loading state
  
  // Filter states
  final String? selectedMachineId;
  final String? selectedBatchId;
  final DateFilterRange dateFilter;
  final String searchQuery;
  final String selectedCategory;
  final String selectedType;
  
  // Sort states
  final String? sortColumn;
  final bool sortAscending;
  
  // Pagination states
  final int? currentPage;
  final int? totalPages;
  final int? itemsPerPage;
  final int? totalItems;
  
  // Callbacks
  final ValueChanged<String?> onMachineChanged;
  final ValueChanged<String?> onBatchChanged;
  final ValueChanged<DateFilterRange> onDateFilterChanged;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onCategoryChanged;
  final ValueChanged<String> onTypeChanged;
  final ValueChanged<String> onSort;
  final ValueChanged<ActivityLogItem> onViewDetails;
  final ValueChanged<int>? onPageChanged;
  final ValueChanged<int>? onItemsPerPageChanged;

  const UnifiedTableContainer({
    super.key,
    required this.items,
    required this.isLoading, // NEW: Required loading state
    required this.selectedMachineId,
    required this.selectedBatchId,
    required this.dateFilter,
    required this.searchQuery,
    required this.selectedCategory,
    required this.selectedType,
    required this.sortColumn,
    required this.sortAscending,
    required this.onMachineChanged,
    required this.onBatchChanged,
    required this.onDateFilterChanged,
    required this.onSearchChanged,
    required this.onCategoryChanged,
    required this.onTypeChanged,
    required this.onSort,
    required this.onViewDetails,
    this.currentPage,
    this.totalPages,
    this.itemsPerPage,
    this.totalItems,
    this.onPageChanged,
    this.onItemsPerPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return BaseTableContainer(
      // Left header: Machine and Batch selectors
      leftHeaderWidget: Row(
        children: [
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
        ],
      ),
      
      // Right header: Date filter and Search
      rightHeaderWidgets: [
        SizedBox(
          height: 32,
          child: DateFilterDropdown(
            onFilterChanged: onDateFilterChanged,
          ),
        ),
        SearchField(
          onChanged: onSearchChanged,
        ),
      ],
      
      // Table header
      tableHeader: ActivityTableHeader(
        selectedCategory: selectedCategory,
        selectedType: selectedType,
        sortColumn: sortColumn,
        sortAscending: sortAscending,
        onCategoryChanged: onCategoryChanged,
        onTypeChanged: onTypeChanged,
        onSort: onSort,
      ),
      
      // Table body - NOW WITH LOADING STATE
      tableBody: ActivityTableBody(
        items: items,
        onViewDetails: onViewDetails,
        isLoading: isLoading, // NEW: Pass loading state
      ),
      
      // Pagination (if provided)
      paginationWidget: (currentPage != null && totalPages != null && itemsPerPage != null)
          ? PaginationControls(
              currentPage: currentPage!,
              totalPages: totalPages!,
              itemsPerPage: itemsPerPage!,
              onPageChanged: onPageChanged,
              onItemsPerPageChanged: onItemsPerPageChanged,
            )
          : null,
    );
  }
}