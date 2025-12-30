// lib/ui/machine_management/widgets/admin/table/machine_table_row.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../data/models/machine_model.dart';
import '../../core/constants/spacing.dart';
import '../../core/themes/web_colors.dart';
import '../../core/themes/web_text_styles.dart';

class MachineTableRow extends StatelessWidget {
  final MachineModel machine;
  final ValueChanged<MachineModel> onViewDetails;
  final ValueChanged<MachineModel> onEdit;

  const MachineTableRow({
    super.key,
    required this.machine,
    required this.onViewDetails,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy');

    return Container(
      constraints: const BoxConstraints(minHeight: 52),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.tableCellHorizontal,
        vertical: 8,
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              machine.machineId,
              style: WebTextStyles.body,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            flex: 3,
            child: Text(
              machine.machineName,
              style: WebTextStyles.body,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            flex: 2,
            child: Text(
              dateFormat.format(machine.dateCreated),
              style: WebTextStyles.body,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            flex: 2,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: machine.isArchived
                      ? WebColors.error.withValues(alpha: 0.1)
                      : WebColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: machine.isArchived
                        ? WebColors.error.withValues(alpha: 0.3)
                        : WebColors.success.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  machine.isArchived ? 'Archived' : 'Active',
                  style: WebTextStyles.label.copyWith(
                    fontSize: 12,
                    color: machine.isArchived
                        ? WebColors.error
                        : WebColors.success,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            flex: 2,
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    color: WebColors.textLabel,
                    onPressed: () => onEdit(machine),
                    tooltip: 'Edit Machine',
                  ),
                  IconButton(
                    icon: const Icon(Icons.open_in_new, size: 18),
                    color: WebColors.textLabel,
                    onPressed: () => onViewDetails(machine),
                    tooltip: 'View Details',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}