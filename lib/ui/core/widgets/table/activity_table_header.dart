// lib/ui/core/widgets/table/activity_table_header.dart

import 'package:flutter/material.dart';
import '../../../activity_logs/models/unified_activity_config.dart';
import '../../../activity_logs/models/activity_enums.dart';
import '../../constants/spacing.dart';
import '../../themes/web_text_styles.dart';
import '../filters/filter_dropdown.dart';
import 'activity_table_row.dart';

/// Table header row with sortable columns and filter dropdowns
/// NOW USES ENUMS instead of strings
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

  @override
  Widget build(BuildContext context) {
    final availableTypes = UnifiedActivityConfig.getSubTypesForCategory(selectedCategory);
    
    // Validate that selectedType is valid for selectedCategory
    final validType = availableTypes.contains(selectedType) 
        ? selectedType 
        : ActivitySubType.all;

    return Opacity(
      opacity: isLoading ? 0.7 : 1.0,
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFF0F8FF), // Light blue header background
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(8),
            topRight: Radius.circular(8),
          ),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.tableCellHorizontal,
          vertical: 8,
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
                onSort: isLoading ? null : () => onSort('title'),
              ),
            ),
            
            const SizedBox(width: AppSpacing.md),
            
            // Category Column with Dropdown
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
            
            const SizedBox(width: AppSpacing.md),
            
            // Type Column with Dropdown
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
                onSort: isLoading ? null : () => onSort('date'),
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
      ),
    );
  }
}