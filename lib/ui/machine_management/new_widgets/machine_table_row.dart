// lib/ui/machine_management/new_widgets/machine_table_row.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/models/machine_model.dart';
import '../../core/constants/spacing.dart';
import '../../core/themes/web_text_styles.dart';
import '../../core/themes/web_colors.dart';
import '../../core/widgets/table/activity_table_row.dart';

// Single machine row in table
class MachineTableRow extends StatelessWidget {
  final MachineModel machine;
  final VoidCallback onEdit;
  final VoidCallback onView;

  const MachineTableRow({
    super.key,
    required this.machine,
    required this.onEdit,
    required this.onView,
  });

  Color get statusColor {
    switch (machine.status) {
      case MachineStatus.active:
        return WebColors.success;
      case MachineStatus.inactive:
        return WebColors.warning;
      case MachineStatus.underMaintenance:
        return WebColors.error;
    }
  }

  String get statusText {
    switch (machine.status) {
      case MachineStatus.active:
        return 'Active';
      case MachineStatus.inactive:
        return 'Archived';
      case MachineStatus.underMaintenance:
        return 'Suspended';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GenericTableRow(
      onTap: null,
      hoverColor: WebColors.hoverBackground,
      cellSpacing: AppSpacing.md,
      cells: [
        // Machine ID Column
        TableCellWidget(
          flex: 2,
          child: Text(
            machine.machineId,
            style: WebTextStyles.body,
            textAlign: TextAlign.center,
          ),
        ),
        
        // Machine Name Column
        TableCellWidget(
          flex: 2,
          child: Text(
            machine.machineName,
            style: WebTextStyles.body,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ),
        
        // Date Added Column
        TableCellWidget(
          flex: 2,
          child: Text(
            DateFormat('MMM dd, yyyy').format(machine.dateCreated),
            style: WebTextStyles.body,
            textAlign: TextAlign.center,
          ),
        ),
        
        // Status Chip (filled background)
        TableCellWidget(
          flex: 2,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                statusText,
                style: WebTextStyles.label.copyWith(
                  fontSize: 12,
                  color: statusColor,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
        
        // Actions Column (View and Edit icons)
        TableCellWidget(
          flex: 1,
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.visibility_outlined, size: 18),
                  color: WebColors.textLabel,
                  onPressed: onView,
                  tooltip: 'View Details',
                ),
                const SizedBox(width: 4),
                IconButton(
                  icon: const Icon(Icons.edit, size: 18),
                  color: WebColors.textLabel,
                  onPressed: onEdit,
                  tooltip: 'Edit Machine',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}