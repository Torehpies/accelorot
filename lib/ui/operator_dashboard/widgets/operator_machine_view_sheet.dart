// lib/ui/operator_dashboard/widgets/operator_machine_view_sheet.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/models/machine_model.dart';
import '../../core/widgets/bottom_sheets/mobile_bottom_sheet_base.dart';
import '../../core/widgets/bottom_sheets/mobile_bottom_sheet_buttons.dart';
import '../../core/widgets/bottom_sheets/fields/mobile_readonly_field.dart';
import '../../core/widgets/bottom_sheets/fields/mobile_readonly_section.dart';
import '../../machine_detail_screen/widgets/drum_control.dart';
import '../../machine_detail_screen/widgets/aerator_control.dart';

class OperatorMachineViewSheet extends StatelessWidget {
  final MachineModel machine;

  const OperatorMachineViewSheet({
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: DrumControl(machine: machine),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AeratorControl(machine: machine),
                ),
              ],
            ),
          ),
          MobileReadOnlySection(
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
        ],
      ),
    );
  }
}
