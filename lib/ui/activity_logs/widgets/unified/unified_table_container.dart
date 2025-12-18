// lib/ui/activity_logs/widgets/unified/unified_table_container.dart

import 'package:flutter/material.dart';
import '../../../../data/models/activity_log_item.dart';
import '../../models/activity_common.dart';
import '../../../core/constants/spacing.dart';
import '../../../core/widgets/shared/pagination_controls.dart';
import '../../../core/widgets/table/activity_filter_bar.dart';
import '../../../core/widgets/table/activity_table_header.dart';
import '../../../core/widgets/table/activity_table_body.dart';

/// Unified container that composes filter bar, table header, body, and pagination
class UnifiedTableContainer extends StatelessWidget {
  final List<ActivityLogItem> items;
  
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
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          // Filter Bar Section
          ActivityFilterBar(
            selectedMachineId: selectedMachineId,
            selectedBatchId: selectedBatchId,
            dateFilter: dateFilter,
            searchQuery: searchQuery,
            onMachineChanged: onMachineChanged,
            onBatchChanged: onBatchChanged,
            onDateFilterChanged: onDateFilterChanged,
            onSearchChanged: onSearchChanged,
          ),
          
          // Divider
          const Divider(height: 1, color: Color(0xFFE5E7EB)),
          
          // Table Header
          ActivityTableHeader(
            selectedCategory: selectedCategory,
            selectedType: selectedType,
            sortColumn: sortColumn,
            sortAscending: sortAscending,
            onCategoryChanged: onCategoryChanged,
            onTypeChanged: onTypeChanged,
            onSort: onSort,
          ),
          
          // Table Body
          Expanded(
            child: ActivityTableBody(
              items: items,
              onViewDetails: onViewDetails,
            ),
          ),
          
          // Pagination Footer
          if (currentPage != null && totalPages != null && itemsPerPage != null) ...[
            const Divider(height: 1, color: Color(0xFFE5E7EB)),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.tableCellHorizontal,
                vertical: AppSpacing.lg,
              ),
              child: PaginationControls(
                currentPage: currentPage!,
                totalPages: totalPages!,
                itemsPerPage: itemsPerPage!,
                onPageChanged: onPageChanged,
                onItemsPerPageChanged: onItemsPerPageChanged,
              ),
            ),
          ],
        ],
      ),
    );
  }
}