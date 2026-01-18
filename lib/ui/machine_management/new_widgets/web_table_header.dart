// lib/ui/machine_management/new_widgets/web_table_header.dart

import 'package:flutter/material.dart';
import '../../../data/models/machine_model.dart';
import '../../core/widgets/table/table_row.dart';
import '../../core/widgets/filters/filter_dropdown.dart';
import '../../core/themes/web_text_styles.dart';
import '../../core/themes/web_colors.dart';
import '../../core/constants/spacing.dart';

class MachineTableHeader extends StatelessWidget {
  final MachineStatusFilter selectedStatusFilter;
  final String? sortColumn;
  final bool sortAscending;
  final ValueChanged<MachineStatusFilter> onStatusFilterChanged;
  final ValueChanged<String> onSort;
  final bool isLoading;

  const MachineTableHeader({
    super.key,
    required this.selectedStatusFilter,
    required this.sortColumn,
    required this.sortAscending,
    required this.onStatusFilterChanged,
    required this.onSort,
    this.isLoading = false,
  });

  bool _isStatusFilterActive() {
    return selectedStatusFilter != MachineStatusFilter.all;
  }

  @override
  Widget build(BuildContext context) {
    final isStatusActive = _isStatusFilterActive();

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
            // Machine ID Column (sortable)
            Expanded(
              flex: 2,
              child: TableHeaderCell(
                label: 'Machine ID',
                sortable: true,
                sortColumn: 'machineId',
                currentSortColumn: sortColumn,
                sortAscending: sortAscending,
                onSort: isLoading ? null : () => onSort('machineId'),
              ),
            ),
            
            const SizedBox(width: AppSpacing.md),
            
            // Name Column (sortable)
            Expanded(
              flex: 2,
              child: TableHeaderCell(
                label: 'Name',
                sortable: true,
                sortColumn: 'name',
                currentSortColumn: sortColumn,
                sortAscending: sortAscending,
                onSort: isLoading ? null : () => onSort('name'),
              ),
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
            
            // Status Column with Dropdown
            Expanded(
              flex: 2,
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Status',
                      style: WebTextStyles.label.copyWith(
                        color: isStatusActive ? WebColors.greenAccent : WebColors.textLabel,
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilterDropdown<MachineStatusFilter>(
                      label: 'Status',
                      value: selectedStatusFilter,
                      items: MachineStatusFilter.values,
                      displayName: (filter) => filter.displayName,
                      onChanged: onStatusFilterChanged,
                      isLoading: isLoading,
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(width: AppSpacing.md),
            
            // Actions Column
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