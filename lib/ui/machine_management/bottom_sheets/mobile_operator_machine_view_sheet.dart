// lib/ui/machine_management/bottom_sheets/mobile_operator_machine_view_sheet.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/models/machine_model.dart';
import '../../core/bottom_sheet/mobile_bottom_sheet_base.dart';
import '../../core/bottom_sheet/mobile_bottom_sheet_buttons.dart';
import '../../core/bottom_sheet/fields/mobile_readonly_field.dart';
import '../../core/bottom_sheet/fields/mobile_readonly_section.dart';

class MobileOperatorMachineViewSheet extends StatelessWidget {
  final MachineModel machine;

  const MobileOperatorMachineViewSheet({
    super.key,
    required this.machine,
  });

  String get _statusText {
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
    return MobileBottomSheetBase(
      title: machine.machineName,
      subtitle: 'Machine Details',
      actions: [
        BottomSheetAction.secondary(
          label: 'Close',
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
      body: MobileReadOnlySection(
        sectionTitle: null,
        fields: [
          MobileReadOnlyField(label: 'Machine ID', value: machine.machineId),
          MobileReadOnlyField(label: 'Status', value: _statusText),
          MobileReadOnlyField(
            label: 'Current Batch',
            value: machine.currentBatchId ?? 'No active batch',
          ),
          MobileReadOnlyField(
            label: 'Date Created',
            value: DateFormat('MMM dd, yyyy').format(machine.dateCreated),
          ),
          MobileReadOnlyField(
            label: 'Last Modified',
            value: machine.lastModified != null
                ? DateFormat('MMM dd, yyyy').format(machine.lastModified!)
                : 'Never',
          ),
        ],
      ),
    );
  }
}