// lib/ui/machine_management/dialogs/web_admin_view_details_dialog.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/models/machine_model.dart';
import '../../core/dialog/base_dialog.dart';
import '../../core/dialog/dialog_action.dart';
import '../../core/dialog/dialog_fields.dart';

class WebAdminViewDetailsDialog extends StatelessWidget {
  final MachineModel machine;
  final VoidCallback onArchive;

  const WebAdminViewDetailsDialog({
    super.key,
    required this.machine,
    required this.onArchive,
  });

  String get statusText {
    switch (machine.status) {
      case MachineStatus.active:
        return 'Active';
      case MachineStatus.inactive:
        return 'Inactive';
      case MachineStatus.underMaintenance:
        return 'Suspended';
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseDialog(
      title: machine.machineName,
      subtitle: 'Machine Details',
      maxHeightFactor: 0.6,
      content: ReadOnlySection(
        fields: [
          ReadOnlyField(
            label: 'Machine ID',
            value: machine.machineId,
          ),
          ReadOnlyField(
            label: 'Status',
            value: statusText,
          ),
          ReadOnlyField(
            label: 'Current Batch',
            value: machine.currentBatchId ?? 'No active batch',
          ),
          ReadOnlyField(
            label: 'Date Created',
            value: DateFormat('MMM dd, yyyy').format(machine.dateCreated),
          ),
          ReadOnlyField(
            label: 'Last Modified',
            value: machine.lastModified != null
                ? DateFormat('MMM dd, yyyy').format(machine.lastModified!)
                : 'Never',
          ),
        ],
      ),
      actions: [
        DialogAction.secondary(
          label: 'Close',
          onPressed: () => Navigator.of(context).pop(),
        ),
        DialogAction.destructive(
          label: 'Archive',
          onPressed: () {
            Navigator.of(context).pop();
            onArchive();
          },
        ),
      ],
    );
  }
}