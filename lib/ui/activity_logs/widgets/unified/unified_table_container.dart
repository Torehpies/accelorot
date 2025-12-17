// lib/ui/activity_logs/widgets/unified/unified_table_container.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../data/models/activity_log_item.dart';
import '../../models/unified_activity_config.dart';
import '../../models/activity_common.dart';
import '../machine_selector.dart';
import '../batch_selector.dart';
import '../date_filter_button.dart';
import '../../../core/constants/spacing.dart';
import '../../../core/widgets/shared/empty_state.dart';
import '../../../core/widgets/shared/pagination_controls.dart';
import '../../../core/widgets/table/table_badge.dart';
import '../../../core/widgets/table/table_chip.dart';
import '../../../core/widgets/table/table_header_cell.dart';
import '../../../core/widgets/filters/filter_dropdown.dart';

/// Unified container that merges filter bar and table into one cohesive component
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
          _buildFilterBar(),
          
          // Divider
          const Divider(height: 1, color: Color(0xFFE5E7EB)),
          
          // Table Header
          _buildTableHeader(),
          
          // Table Body
          Expanded(
            child: items.isEmpty
                ? const EmptyState()
                : ListView.separated(
                    itemCount: items.length,
                    separatorBuilder: (context, index) => const Divider(
                      height: 1,
                      color: Color(0xFFE5E7EB),
                    ),
                    itemBuilder: (context, index) {
                      return _buildTableRow(context, items[index]);
                    },
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

  // ===== FILTER BAR SECTION =====
  
  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Row(
        children: [
          // Machine Selector
          Expanded(
            flex: 2,
            child: SizedBox(
              height: 32,
              child: MachineSelector(
                selectedMachineId: selectedMachineId,
                onChanged: onMachineChanged,
                isCompact: true,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          
          // Batch Selector
          Expanded(
            flex: 2,
            child: SizedBox(
              height: 32,
              child: BatchSelector(
                selectedBatchId: selectedBatchId,
                selectedMachineId: selectedMachineId,
                onChanged: onBatchChanged,
                isCompact: true,
                showLabel: false,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          
          // Date Filter Button
          SizedBox(
            height: 32,
            child: DateFilterButton(
              onFilterChanged: onDateFilterChanged,
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          
          // Search Bar
          Expanded(
            flex: 3,
            child: Container(
              height: 32,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
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
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: TextField(
                      onChanged: onSearchChanged,
                      decoration: const InputDecoration(
                        hintText: 'Search...',
                        hintStyle: TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF6B7280),
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                        isDense: true,
                      ),
                      style: const TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 13,
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

  // ===== TABLE HEADER =====
  
  Widget _buildTableHeader() {
    final availableTypes = UnifiedActivityConfig.getTypesForCategory(selectedCategory);
    final validType = availableTypes.contains(selectedType) ? selectedType : 'All';

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.tableCellHorizontal,
        vertical: AppSpacing.tableHeaderVertical,
      ),
      child: Row(
        children: [
          // Title Column (sortable)
          Expanded(
            flex: 4,
            child: TableHeaderCell(
              label: 'Title',
              sortable: true,
              sortColumn: 'title',
              currentSortColumn: sortColumn,
              sortAscending: sortAscending,
              onSort: () => onSort('title'),
            ),
          ),
          
          const SizedBox(width: AppSpacing.md),
          
          // Category Dropdown
          Expanded(
            flex: 2,
            child: FilterDropdown(
              label: 'Category',
              value: selectedCategory,
              items: UnifiedActivityConfig.categories,
              onChanged: onCategoryChanged,
            ),
          ),
          
          const SizedBox(width: AppSpacing.md),
          
          // Type Dropdown
          Expanded(
            flex: 2,
            child: FilterDropdown(
              label: 'Type',
              value: validType,
              items: availableTypes,
              onChanged: onTypeChanged,
            ),
          ),
          
          const SizedBox(width: AppSpacing.md),
          
          // Value Column Header
          Expanded(
            flex: 2,
            child: TableHeaderCell(label: 'Value'),
          ),
          
          const SizedBox(width: AppSpacing.md),
          
          // Date Added Column (sortable)
          Expanded(
            flex: 2,
            child: TableHeaderCell(
              label: 'Date Added',
              sortable: true,
              sortColumn: 'date',
              currentSortColumn: sortColumn,
              sortAscending: sortAscending,
              onSort: () => onSort('date'),
            ),
          ),
          
          const SizedBox(width: AppSpacing.md),
          
          // Actions Column Header
          const SizedBox(
            width: 70,
            child: Text(
              'Actions',
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6B7280),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===== TABLE ROWS =====
  
  Widget _buildTableRow(BuildContext context, ActivityLogItem item) {
    final categoryName = UnifiedActivityConfig.getCategoryNameFromActivityType(item.type);
    final typeColor = UnifiedActivityConfig.getColorForType(item.category);

    return InkWell(
      onTap: () => onViewDetails(item),
      hoverColor: const Color(0xFFF9FAFB),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.tableCellHorizontal,
          vertical: AppSpacing.tableCellVertical,
        ),
        child: Row(
          children: [
            // Title Column
            Expanded(
              flex: 4,
              child: Text(
                item.title,
                style: const TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF111827),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.left,
              ),
            ),
            
            const SizedBox(width: AppSpacing.md),
            
            // Category Badge
            SizedBox(
              child: TableBadge(text: categoryName),
            ),
            
            const SizedBox(width: AppSpacing.md),
            
            // Type Chip
            SizedBox(
              child: TableChip(text: item.category, color: typeColor),
            ),
            
            const Spacer(),
            
            const SizedBox(width: AppSpacing.md),
            
            // Value Column
            Expanded(
              flex: 2,
              child: Text(
                item.value,
                style: const TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF111827),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            
            const SizedBox(width: AppSpacing.md),
            
            // Date Added Column
            Expanded(
              flex: 2,
              child: Text(
                DateFormat('MM/dd/yyyy').format(item.timestamp),
                style: const TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF111827),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            
            const SizedBox(width: AppSpacing.md),
            
            // Actions Column
            SizedBox(
              width: 70,
              child: IconButton(
                icon: const Icon(Icons.visibility_outlined, size: 18),
                color: const Color(0xFF6B7280),
                onPressed: () => onViewDetails(item),
              ),
            ),
          ],
        ),
      ),
    );
  }
}