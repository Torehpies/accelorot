// lib/ui/core/widgets/table/activity_table_header.dart

import 'package:flutter/material.dart';
import '../../../activity_logs/models/unified_activity_config.dart';
import '../../constants/spacing.dart';
import '../filters/filter_dropdown.dart';
import 'table_header_cell.dart';

/// Table header row with sortable columns and filter dropdowns
class ActivityTableHeader extends StatelessWidget {
  final String selectedCategory;
  final String selectedType;
  final String? sortColumn;
  final bool sortAscending;
  final ValueChanged<String> onCategoryChanged;
  final ValueChanged<String> onTypeChanged;
  final ValueChanged<String> onSort;

  const ActivityTableHeader({
    super.key,
    required this.selectedCategory,
    required this.selectedType,
    required this.sortColumn,
    required this.sortAscending,
    required this.onCategoryChanged,
    required this.onTypeChanged,
    required this.onSort,
  });

  @override
  Widget build(BuildContext context) {
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
            flex: 2,
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
          
          // Category Column with Static Label
          Expanded(
            flex: 2,
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Category:',
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilterDropdown(
                    label: 'Category',
                    value: selectedCategory,
                    items: UnifiedActivityConfig.categories,
                    onChanged: onCategoryChanged,
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(width: AppSpacing.md),
          
          // Type Column with Static Label
          Expanded(
            flex: 2,
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Type:',
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilterDropdown(
                    label: 'Type',
                    value: validType,
                    items: availableTypes,
                    onChanged: onTypeChanged,
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(width: AppSpacing.md),
          
          // Value Column Header
          const Expanded(
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
          const Expanded(
            flex: 1,
            child: Center(
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
          ),
        ],
      ),
    );
  }
}