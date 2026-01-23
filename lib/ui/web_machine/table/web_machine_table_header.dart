// lib/ui/machine_management/widgets/admin/table/machine_table_header.dart

import 'package:flutter/material.dart';
import '../../core/constants/spacing.dart';
import '../../core/themes/web_colors.dart';
import '../../core/themes/web_text_styles.dart';
import 'web_machine_table_header_cell.dart';

class MachineTableHeader extends StatelessWidget {
  final String sortColumn;
  final bool ascending;
  final String statusFilter;
  final Function(String) onSort;
  final Function(String) onStatusChanged;
  final bool isLoading;

  const MachineTableHeader({
    super.key,
    required this.sortColumn,
    required this.ascending,
    required this.statusFilter,
    required this.onSort,
    required this.onStatusChanged,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
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
            Expanded(
              flex: 2,
              child: MachineTableHeaderCell(
                label: 'Machine ID',
                sortable: true,
                sortColumn: 'ID',
                currentSortColumn: sortColumn,
                sortAscending: ascending,
                onSort: isLoading ? null : () => onSort('ID'),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              flex: 3,
              child: MachineTableHeaderCell(
                label: 'Name',
                sortable: true,
                sortColumn: 'Name',
                currentSortColumn: sortColumn,
                sortAscending: ascending,
                onSort: isLoading ? null : () => onSort('Name'),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              flex: 2,
              child: MachineTableHeaderCell(
                label: 'Date Added',
                sortable: true,
                sortColumn: 'Created',
                currentSortColumn: sortColumn,
                sortAscending: ascending,
                onSort: isLoading ? null : () => onSort('Created'),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              flex: 2,
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Status',
                      style: WebTextStyles.label.copyWith(
                        color: statusFilter != 'All'
                            ? WebColors.success
                            : WebColors.textLabel,
                      ),
                    ),
                    const SizedBox(width: 4),
                    MouseRegion(
                      cursor: isLoading
                          ? SystemMouseCursors.basic
                          : SystemMouseCursors.click,
                      child: PopupMenuButton<String>(
                        icon: Icon(
                          Icons.arrow_drop_down,
                          size: 20,
                          color: statusFilter != 'All'
                              ? WebColors.success
                              : WebColors.textLabel,
                        ),
                        offset: const Offset(0, 35),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 8,
                        color: WebColors.cardBackground,
                        enabled: !isLoading,
                        onSelected: (value) => onStatusChanged(value),
                        itemBuilder: (context) {
                          return ['All', 'Active', 'Archived']
                              .map(
                                (status) => PopupMenuItem(
                                  value: status,
                                  child: Row(
                                    children: [
                                      if (statusFilter == status)
                                        const Icon(
                                          Icons.check,
                                          size: 16,
                                          color: WebColors.success,
                                        ),
                                      if (statusFilter == status)
                                        const SizedBox(width: 8),
                                      Text(
                                        status,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: statusFilter == status
                                              ? FontWeight.w600
                                              : FontWeight.normal,
                                          color: statusFilter == status
                                              ? WebColors.success
                                              : WebColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                              .toList();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            const Expanded(
              flex: 2,
              child: Center(child: Text('Actions', style: WebTextStyles.label)),
            ),
          ],
        ),
      ),
    );
  }
}
