// lib/ui/machine_management/new_widgets/machine_table_header.dart

import 'package:flutter/material.dart';
import '../../../data/models/machine_model.dart';
import '../../core/widgets/table/activity_table_row.dart';
import '../../core/themes/web_text_styles.dart';
import '../../core/themes/web_colors.dart';
import '../../core/constants/spacing.dart';

class MachineTableHeader extends StatelessWidget {
  final MachineStatus? selectedStatus;
  final String? sortColumn;
  final bool sortAscending;
  final ValueChanged<MachineStatus?> onStatusChanged;
  final ValueChanged<String> onSort;
  final bool isLoading;

  const MachineTableHeader({
    super.key,
    required this.selectedStatus,
    required this.sortColumn,
    required this.sortAscending,
    required this.onStatusChanged,
    required this.onSort,
    this.isLoading = false,
  });

  bool _isStatusFilterActive() {
    return selectedStatus != null;
  }

  @override
  Widget build(BuildContext context) {
    final isStatusActive = _isStatusFilterActive();
    final isMachineIdActive = sortColumn == 'machineId';
    final isNameActive = sortColumn == 'name';
    final isDateActive = sortColumn == 'date';

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
                        color: isStatusActive ? WebColors.tealAccent : WebColors.textLabel,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _StatusDropdown(
                      selectedStatus: selectedStatus,
                      onChanged: onStatusChanged,
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

class _StatusDropdown extends StatefulWidget {
  final MachineStatus? selectedStatus;
  final ValueChanged<MachineStatus?> onChanged;
  final bool isLoading;

  const _StatusDropdown({
    required this.selectedStatus,
    required this.onChanged,
    this.isLoading = false,
  });

  @override
  State<_StatusDropdown> createState() => _StatusDropdownState();
}

class _StatusDropdownState extends State<_StatusDropdown> {
  bool _isHovered = false;

  String _getDisplayText(MachineStatus? status) {
    if (status == null) return 'All';
    switch (status) {
      case MachineStatus.active:
        return 'Active';
      case MachineStatus.inactive:
        return 'Inactive';
      case MachineStatus.underMaintenance:
        return 'Suspended';
    }
  }

  void _showFilterMenu(BuildContext context) async {
    if (widget.isLoading) return;

    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset.zero, ancestor: overlay),
        button.localToGlobal(button.size.bottomRight(Offset.zero), ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );

    final MachineStatus? selected = await showMenu<MachineStatus?>(
      context: context,
      position: position,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      elevation: 8,
      color: WebColors.cardBackground,
      items: [
        const PopupMenuItem<MachineStatus?>(
          value: null,
          child: Text('All'),
        ),
        ...MachineStatus.values.map((status) {
          return PopupMenuItem<MachineStatus?>(
            value: status,
            child: Text(_getDisplayText(status)),
          );
        }),
      ],
    );

    if (selected != widget.selectedStatus) {
      widget.onChanged(selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isActive = widget.selectedStatus != null;
    final iconColor = isActive ? WebColors.tealAccent : WebColors.textLabel;

    return MouseRegion(
      cursor: widget.isLoading ? SystemMouseCursors.basic : SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Opacity(
        opacity: widget.isLoading ? 0.5 : 1.0,
        child: InkWell(
          onTap: widget.isLoading ? null : () => _showFilterMenu(context),
          borderRadius: BorderRadius.circular(4),
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Icon(
              Icons.filter_alt,
              size: 18,
              color: _isHovered 
                ? (isActive ? WebColors.tealAccent.withValues(alpha: 0.8) : WebColors.textSecondary)
                : iconColor,
            ),
          ),
        ),
      ),
    );
  }
}