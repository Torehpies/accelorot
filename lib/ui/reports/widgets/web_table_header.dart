// lib/ui/reports/widgets/web_table_header.dart

import 'package:flutter/material.dart';
import '../models/reports_state.dart';
import '../../core/widgets/filters/filter_dropdown.dart';
import '../../core/widgets/table/table_row.dart';
import '../../core/themes/web_text_styles.dart';
import '../../core/themes/web_colors.dart';
import '../../core/constants/spacing.dart';

class WebTableHeader extends StatelessWidget {
  final ReportStatusFilter selectedStatus;
  final ReportCategoryFilter selectedCategory;
  final ReportPriorityFilter selectedPriority;
  final String? sortColumn;
  final bool sortAscending;
  final ValueChanged<ReportStatusFilter> onStatusChanged;
  final ValueChanged<ReportCategoryFilter> onCategoryChanged;
  final ValueChanged<ReportPriorityFilter> onPriorityChanged;
  final ValueChanged<String> onSort;
  final bool isLoading;

  const WebTableHeader({
    super.key,
    required this.selectedStatus,
    required this.selectedCategory,
    required this.selectedPriority,
    required this.sortColumn,
    required this.sortAscending,
    required this.onStatusChanged,
    required this.onCategoryChanged,
    required this.onPriorityChanged,
    required this.onSort,
    this.isLoading = false,
  });

  bool _isFilterActive(String filterValue) {
    return !filterValue.toLowerCase().contains('all');
  }

  @override
  Widget build(BuildContext context) {
    final isCategoryActive = _isFilterActive(selectedCategory.displayName);
    final isStatusActive = _isFilterActive(selectedStatus.displayName);
    final isPriorityActive = _isFilterActive(selectedPriority.displayName);
    final isTitleActive = sortColumn == 'title';

    return Opacity(
      opacity: isLoading ? 0.7 : 1.0,
      child: Container(
        decoration: const BoxDecoration(
          color: WebColors.pageBackground,
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
            // Title Column (sortable, flex: 2)
            Expanded(
              flex: 2,
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Title',
                      style: WebTextStyles.label.copyWith(
                        color: isTitleActive
                            ? WebColors.greenAccent
                            : WebColors.textLabel,
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

            const SizedBox(width: AppSpacing.md),

            // Category Column with Dropdown (flex: 2)
            Expanded(
              flex: 2,
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Category',
                      style: WebTextStyles.label.copyWith(
                        color: isCategoryActive
                            ? WebColors.greenAccent
                            : WebColors.textLabel,
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilterDropdown<ReportCategoryFilter>(
                      label: 'Category',
                      value: selectedCategory,
                      items: ReportCategoryFilter.values,
                      displayName: (cat) => cat.displayName,
                      onChanged: onCategoryChanged,
                      isLoading: isLoading,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(width: AppSpacing.md),

            // Status Column with Dropdown (flex: 2)
            Expanded(
              flex: 2,
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Status',
                      style: WebTextStyles.label.copyWith(
                        color: isStatusActive
                            ? WebColors.greenAccent
                            : WebColors.textLabel,
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilterDropdown<ReportStatusFilter>(
                      label: 'Status',
                      value: selectedStatus,
                      items: ReportStatusFilter.values,
                      displayName: (status) => status.displayName,
                      onChanged: onStatusChanged,
                      isLoading: isLoading,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(width: AppSpacing.md),

            // Priority Column with Dropdown (flex: 2)
            Expanded(
              flex: 2,
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Priority:',
                      style: WebTextStyles.label.copyWith(
                        color: isPriorityActive
                            ? WebColors.greenAccent
                            : WebColors.textLabel,
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilterDropdown<ReportPriorityFilter>(
                      label: 'Priority',
                      value: selectedPriority,
                      items: ReportPriorityFilter.values,
                      displayName: (priority) => priority.displayName,
                      onChanged: onPriorityChanged,
                      isLoading: isLoading,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(width: AppSpacing.md),

            // Actions Column Header (flex: 1)
            const Expanded(
              flex: 1,
              child: Center(child: Text('Actions', style: WebTextStyles.label)),
            ),
          ],
        ),
      ),
    );
  }
}
