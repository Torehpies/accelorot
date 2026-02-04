// lib/ui/reports/widgets/web_table_header.dart

import 'package:flutter/material.dart';
import '../../core/widgets/filters/filter_dropdown.dart';
import '../../core/widgets/table/table_header.dart';
import '../../core/widgets/table/table_row.dart';
import '../../core/themes/web_text_styles.dart';
import '../../core/themes/web_colors.dart';
import '../models/report_filters.dart';

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

    return TableHeader(
      isLoading: isLoading,
      columns: [
        // Title Column (sortable, flex: 2)
        TableCellWidget(
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

        // Category Column with Dropdown (flex: 2)
        TableCellWidget(
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

        // Status Column with Dropdown (flex: 2)
        TableCellWidget(
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

        // Priority Column with Dropdown (flex: 2)
        TableCellWidget(
          flex: 2,
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Priority',
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

        // Actions Column Header (flex: 1)
        const TableCellWidget(
          flex: 1,
          child: TableHeaderCell(label: 'Actions'),
        ),
      ],
    );
  }
}