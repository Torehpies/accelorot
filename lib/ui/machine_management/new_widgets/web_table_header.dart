// lib/ui/machine_management/new_widgets/web_table_header.dart

import 'package:flutter/material.dart';
import '../../../data/models/machine_model.dart';
import '../../core/widgets/table/table_header.dart';
import '../../core/widgets/table/table_row.dart';
import '../../core/widgets/filters/filter_dropdown.dart';
import '../../core/themes/web_text_styles.dart';
import '../../core/themes/web_colors.dart';

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

    return TableHeader(
      isLoading: isLoading,
      columns: [
        // Machine ID Column (flex: 2)
        TableCellWidget(
          flex: 2,
          child: TableHeaderCell(
            label: 'Machine ID',
            sortable: true,
            sortColumn: 'machineId',
            currentSortColumn: sortColumn,
            sortAscending: sortAscending,
            onSort: () => onSort('machineId'),
          ),
        ),

        // Name Column (flex: 2)
        TableCellWidget(
          flex: 2,
          child: TableHeaderCell(
            label: 'Name',
            sortable: true,
            sortColumn: 'name',
            currentSortColumn: sortColumn,
            sortAscending: sortAscending,
            onSort: () => onSort('name'),
          ),
        ),

        // Date Added Column (flex: 2)
        TableCellWidget(
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

        // Status Column with Filter (flex: 2)
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

        // Actions Column (flex: 1)
        const TableCellWidget(
          flex: 1,
          child: TableHeaderCell(label: 'Actions'),
        ),
      ],
    );
  }
}