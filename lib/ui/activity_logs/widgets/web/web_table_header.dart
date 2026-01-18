// lib/ui/activity_logs/widgets/web/web_table_header.dart

import 'package:flutter/material.dart';
import '../../models/unified_activity_config.dart';
import '../../models/activity_enums.dart';
import '../../../core/themes/web_text_styles.dart';
import '../../../core/themes/web_colors.dart';
import '../../../core/widgets/filters/filter_dropdown.dart';
import '../../../core/widgets/table/table_row.dart';
import '../../../core/widgets/table/table_header.dart';

/// Activity-specific table header with sortable columns and filter dropdowns
class ActivityTableHeader extends StatelessWidget {
  final ActivityCategory selectedCategory;
  final ActivitySubType selectedType;
  final String? sortColumn;
  final bool sortAscending;
  final ValueChanged<ActivityCategory> onCategoryChanged;
  final ValueChanged<ActivitySubType> onTypeChanged;
  final ValueChanged<String> onSort;
  final bool isLoading;

  const ActivityTableHeader({
    super.key,
    required this.selectedCategory,
    required this.selectedType,
    required this.sortColumn,
    required this.sortAscending,
    required this.onCategoryChanged,
    required this.onTypeChanged,
    required this.onSort,
    this.isLoading = false,
  });

  bool _isFilterActive(String filterValue) {
    return !filterValue.toLowerCase().contains('all');
  }

  @override
  Widget build(BuildContext context) {
    final availableTypes = UnifiedActivityConfig.getSubTypesForCategory(selectedCategory);
    
    // Validate that selectedType is valid for selectedCategory
    final validType = availableTypes.contains(selectedType) 
        ? selectedType 
        : ActivitySubType.all;

    final isCategoryActive = _isFilterActive(selectedCategory.displayName);
    final isTypeActive = _isFilterActive(validType.displayName);
    final isTitleActive = sortColumn == 'title';

    return TableHeader(
      isLoading: isLoading,
      columns: [
        // Title Column (sortable)
        Expanded(
          flex: 2,
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Title',
                  style: WebTextStyles.label.copyWith(
                    color: isTitleActive ? WebColors.greenAccent : WebColors.textLabel,
                  ),
                ),
                const SizedBox(width: 4),
                TableHeaderCell(
                  label: '',
                  sortable: true,
                  sortColumn: 'title',
                  currentSortColumn: sortColumn,
                  sortAscending: sortAscending,
                  onSort: isLoading ? null : () => onSort('title'),
                ),
              ],
            ),
          ),
        ),
        
        // Category Column with Dropdown
        Expanded(
          flex: 2,
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Category',
                  style: WebTextStyles.label.copyWith(
                    color: isCategoryActive ? WebColors.greenAccent : WebColors.textLabel,
                  ),
                ),
                const SizedBox(width: 8),
                FilterDropdown<ActivityCategory>(
                  label: 'Category',
                  value: selectedCategory,
                  items: ActivityCategory.values,
                  displayName: (cat) => cat.displayName,
                  onChanged: onCategoryChanged,
                  isLoading: isLoading,
                ),
              ],
            ),
          ),
        ),
        
        // Type Column with Dropdown
        Expanded(
          flex: 2,
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Type',
                  style: WebTextStyles.label.copyWith(
                    color: isTypeActive ? WebColors.greenAccent : WebColors.textLabel,
                  ),
                ),
                const SizedBox(width: 8),
                FilterDropdown<ActivitySubType>(
                  label: 'Type',
                  value: validType,
                  items: availableTypes,
                  displayName: (type) => type.displayName,
                  onChanged: onTypeChanged,
                  isLoading: isLoading,
                ),
              ],
            ),
          ),
        ),
        
        // Value Column Header
        const Expanded(
          flex: 2,
          child: TableHeaderCell(label: 'Value'),
        ),
        
        // Date Added Column (sortable)
        Expanded(
          flex: 2,
          child: TableHeaderCell(
            label: 'Date Added',
            sortable: true,
            sortColumn: 'date',
            currentSortColumn: sortColumn,
            sortAscending: sortAscending,
            onSort: isLoading ? null : () => onSort('date'),
          ),
        ),
        
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
    );
  }
}