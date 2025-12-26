// lib/ui/core/widgets/table/activity_table_header.dart

import 'package:flutter/material.dart';
import '../../../activity_logs/models/unified_activity_config.dart';
import '../../constants/spacing.dart';
import '../../themes/web_text_styles.dart';
import '../filters/filter_dropdown.dart';
import 'activity_table_row.dart'; // UPDATED: Now imports TableHeaderCell from here

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
      decoration: const BoxDecoration(
        color: Color(0xFFF0F8FF), // Light blue header background
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
        ),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.tableCellHorizontal,
        vertical: 8, // Reduced from 12 to 8 - smaller than body rows
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
                    style: WebTextStyles.label,
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
                    style: WebTextStyles.label,
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
                style: WebTextStyles.label,
              ),
            ),
          ),
        ],
      ),
    );
  }
}