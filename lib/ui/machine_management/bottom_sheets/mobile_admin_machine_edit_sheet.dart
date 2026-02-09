import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/models/machine_model.dart';
import '../../core/bottom_sheet/mobile_bottom_sheet_base.dart';
import '../../core/bottom_sheet/mobile_bottom_sheet_buttons.dart';
import '../../core/bottom_sheet/fields/mobile_readonly_field.dart';
import '../../core/bottom_sheet/fields/mobile_readonly_section.dart';
import '../../core/bottom_sheet/fields/mobile_input_field.dart';
import '../../core/bottom_sheet/fields/mobile_dropdown_field.dart';
import '../../core/dialog/mobile_confirmation_dialog.dart';
import '../../core/toast/mobile_toast_service.dart';
import '../../core/toast/toast_type.dart';

typedef UpdateMachineCallback = Future<void> Function({
  required String teamId,
  required String machineId,
  String? machineName,
  MachineStatus? status,
  List<String>? assignedUserIds,
});

class MobileAdminMachineEditSheet extends StatefulWidget {
  final MachineModel machine;
  final String teamId;
  final UpdateMachineCallback onUpdate;

  const MobileAdminMachineEditSheet({
    super.key,
    required this.machine,
    required this.teamId,
    required this.onUpdate,
  });

  @override
  State<MobileAdminMachineEditSheet> createState() =>
      _MobileAdminMachineEditSheetState();
}

class _MobileAdminMachineEditSheetState
    extends State<MobileAdminMachineEditSheet> {
  late final TextEditingController _machineNameController;
  late MachineStatus _status;

  bool _isLoading = false;
  String? _machineNameError;

  @override
  void initState() {
    super.initState();
    _machineNameController =
        TextEditingController(text: widget.machine.machineName);
    _status = widget.machine.status;
  }

  @override
  void dispose() {
    _machineNameController.dispose();
    super.dispose();
  }

  bool get _hasChanges {
    return _machineNameController.text.trim() !=
            widget.machine.machineName.trim() ||
        _status != widget.machine.status;
  }

  bool _validate() {
    setState(() => _machineNameError = null);

    if (_machineNameController.text.trim().isEmpty) {
      setState(() => _machineNameError = 'Machine name cannot be empty');
      return false;
    }
    return true;
  }

  Future<void> _save() async {
    if (!_validate()) return;

    setState(() => _isLoading = true);

    try {
      await widget.onUpdate(
        teamId: widget.teamId,
        machineId: widget.machine.machineId,
        machineName: _machineNameController.text.trim(),
        status: _status,
      );

      if (mounted) {
        MobileToastService.show(
          context,
          message: 'Machine updated successfully',
          type: ToastType.success,
        );
        // Small delay so the toast is visible before the sheet closes
        await Future.delayed(const Duration(milliseconds: 600));
        if (mounted) Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        MobileToastService.show(
          context,
          message: 'Failed to update machine',
          type: ToastType.error,
        );
      }
    }
  }

  Future<void> _cancel() async {
    if (_hasChanges) {
      final result = await MobileConfirmationDialog.show(context);
      if (result == ConfirmResult.confirmed && mounted) {
        Navigator.of(context).pop();
      }
    } else {
      Navigator.of(context).pop();
    }
  }

  static const List<MobileDropdownItem<MachineStatus>> _statusItems = [
    MobileDropdownItem(value: MachineStatus.active, label: 'Active'),
    MobileDropdownItem(value: MachineStatus.inactive, label: 'Inactive'),
    MobileDropdownItem(
      value: MachineStatus.underMaintenance,
      label: 'Suspended',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return MobileBottomSheetBase(
      title: widget.machine.machineName,
      subtitle: 'Edit Machine',
      showCloseButton: false,
      actions: [
        BottomSheetAction.secondary(
          label: 'Cancel',
          onPressed: _isLoading ? null : _cancel,
        ),
        BottomSheetAction.primary(
          label: 'Save',
          onPressed: _isLoading ? null : _save,
          isLoading: _isLoading,
        ),
      ],
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MobileInputField(
            label: 'Machine Name',
            controller: _machineNameController,
            required: true,
            errorText: _machineNameError,
            hintText: 'Enter machine name',
          ),
          const SizedBox(height: 16),

          MobileDropdownField<MachineStatus>(
            label: 'Status',
            value: _status,
            items: _statusItems,
            required: true,
            onChanged: (v) {
              if (v != null) setState(() => _status = v);
            },
          ),
          const SizedBox(height: 24),

          MobileReadOnlySection(
            sectionTitle: 'Additional Information',
            fields: [
              MobileReadOnlyField(
                label: 'Machine ID',
                value: widget.machine.machineId,
              ),
              MobileReadOnlyField(
                label: 'Current Batch',
                value: widget.machine.currentBatchId ?? 'No active batch',
              ),
              MobileReadOnlyField(
                label: 'Date Created',
                value: DateFormat('MMM dd, yyyy').format(
                  widget.machine.dateCreated,
                ),
              ),
              MobileReadOnlyField(
                label: 'Last Modified',
                value: widget.machine.lastModified != null
                    ? DateFormat('MMM dd, yyyy').format(
                        widget.machine.lastModified!,
                      )
                    : 'Never',
              ),
            ],
          ),
        ],
      ),
    );
  }
}