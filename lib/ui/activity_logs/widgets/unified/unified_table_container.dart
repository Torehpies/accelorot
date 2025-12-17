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
          // Filter Bar Section (integrated into container)
          _buildFilterBar(),
          
          // Divider between filter and table
          const Divider(height: 1, color: Color(0xFFE5E7EB)),
          
          // Table Header with Category/Type filters
          _buildTableHeader(),
          
          // Table Body
          Expanded(
            child: items.isEmpty
                ? _buildEmptyState()
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
          const Divider(height: 1, color: Color(0xFFE5E7EB)),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.tableCellHorizontal,
              vertical: AppSpacing.lg,
            ),
            child: onViewDetails != null 
                ? _buildPaginationFooter() 
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPaginationFooter() {
    if (currentPage == null || totalPages == null || itemsPerPage == null) {
      return const SizedBox.shrink();
    }
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Items per page selector
        Row(
          children: [
            const Text(
              'Items per page:',
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 13,
                color: Color(0xFF6B7280),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            DropdownButton<int>(
              value: itemsPerPage,
              items: [10, 25, 50, 100].map((value) {
                return DropdownMenuItem(
                  value: value,
                  child: Text('$value'),
                );
              }).toList(),
              onChanged: onItemsPerPageChanged != null
                  ? (value) {
                      if (value != null) {
                        onItemsPerPageChanged!(value);
                      }
                    }
                  : null,
            ),
          ],
        ),

        // Page navigation
        Row(
          children: [
            Text(
              'Page $currentPage of $totalPages',
              style: const TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 13,
                color: Color(0xFF6B7280),
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
            IconButton(
              icon: const Icon(Icons.chevron_left, size: 20),
              onPressed: (currentPage! > 1 && onPageChanged != null)
                  ? () => onPageChanged!(currentPage! - 1)
                  : null,
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right, size: 20),
              onPressed: (currentPage! < totalPages! && onPageChanged != null)
                  ? () => onPageChanged!(currentPage! + 1)
                  : null,
            ),
          ],
        ),
      ],
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
            child: _buildSortableHeader('Title', 'title'),
          ),
          
          const SizedBox(width: AppSpacing.md),
          
          // Category Dropdown
          Expanded(
            flex: 2,
            child: _buildDropdown(
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
            child: _buildDropdown(
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
            child: _buildStaticHeader('Value'),
          ),
          
          const SizedBox(width: AppSpacing.md),
          
          // Date Added Column (sortable)
          Expanded(
            flex: 2,
            child: _buildSortableHeader('Date Added', 'date'),
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

  Widget _buildSortableHeader(String label, String column) {
    final isActive = sortColumn == column;
    
    return InkWell(
      onTap: () => onSort(column),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isActive ? const Color(0xFF374151) : const Color(0xFF6B7280),
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            isActive
                ? (sortAscending ? Icons.arrow_upward : Icons.arrow_downward)
                : Icons.unfold_more,
            size: 16,
            color: isActive ? const Color(0xFF374151) : const Color(0xFF9CA3AF),
          ),
        ],
      ),
    );
  }

  Widget _buildStaticHeader(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontFamily: 'DM Sans',
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Color(0xFF6B7280),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String> onChanged,
  }) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: value,
        isExpanded: true,
        icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF6B7280), size: 20),
        style: const TextStyle(
          fontFamily: 'DM Sans',
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Color(0xFF374151),
        ),
        items: items.map((item) {
          return DropdownMenuItem(
            value: item,
            child: Text('$label: $item'),
          );
        }).toList(),
        onChanged: (newValue) {
          if (newValue != null) {
            onChanged(newValue);
          }
        },
      ),
    );
  }

  // ===== TABLE ROWS =====
  
  Widget _buildTableRow(BuildContext context, ActivityLogItem item) {
    final categoryName = UnifiedActivityConfig.getCategoryNameFromActivityType(item.type);

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
              child: _buildCategoryBadge(categoryName),
            ),
            
            const SizedBox(width: AppSpacing.md),
            
            // Type Chip
            SizedBox(
              child: _buildTypeChip(item.category),
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

  Widget _buildCategoryBadge(String category) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        category,
        style: const TextStyle(
          fontFamily: 'DM Sans',
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Color(0xFF6B7280),
        ),
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildTypeChip(String type) {
    final color = UnifiedActivityConfig.getColorForType(type);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        type,
        style: TextStyle(
          fontFamily: 'DM Sans',
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  // ===== EMPTY STATE =====
  
  Widget _buildEmptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 56,
              color: Color(0xFFD1D5DB),
            ),
            SizedBox(height: 12),
            Text(
              'No activities found',
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6B7280),
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Try adjusting your filters',
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 13,
                color: Color(0xFF9CA3AF),
              ),
            ),
          ],
        ),
      ),
    );
  }
}