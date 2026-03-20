// lib/ui/machine_management/dialogs/web_admin_edit_dialog.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/models/machine_model.dart';
import '../../core/widgets/dialog/base_dialog.dart';
import '../../core/widgets/dialog/dialog_action.dart';
import '../../core/widgets/dialog/dialog_fields.dart';
import '../../core/widgets/dialog/mobile_confirmation_dialog.dart';
import '../../core/ui/app_snackbar.dart';

typedef UpdateMachineCallback = Future<void> Function({
  required String machineId,
  String? machineName,
  MachineStatus? status,
  List<String>? assignedUserIds,
});

class WebAdminEditDialog extends StatefulWidget {
  final MachineModel machine;
  final UpdateMachineCallback onUpdate;

  const WebAdminEditDialog({
    super.key,
    required this.machine,
    required this.onUpdate,
  });

  @override
  State<WebAdminEditDialog> createState() => _WebAdminEditDialogState();
}

class _WebAdminEditDialogState extends State<WebAdminEditDialog> {
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
        machineId: widget.machine.machineId,
        machineName: _machineNameController.text.trim(),
        status: _status,
      );

      if (mounted) {
        Navigator.of(context).pop();
        AppSnackbar.success(context, 'Machine updated successfully');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        AppSnackbar.error(context, 'Failed to update machine');
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

  static const List<DropdownItem<MachineStatus>> _statusItems = [
    DropdownItem(value: MachineStatus.active, label: 'Active'),
    DropdownItem(value: MachineStatus.inactive, label: 'Inactive'),
    DropdownItem(value: MachineStatus.underMaintenance, label: 'Suspended'),
  ];

  MachineModel get machine => widget.machine;

  @override
  Widget build(BuildContext context) {
    return BaseDialog(
      title: machine.machineName,
      subtitle: 'Edit Machine',
      canClose: !_isLoading,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InputField(
            label: 'Machine Name',
            controller: _machineNameController,
            hintText: 'Enter machine name',
            errorText: _machineNameError,
            enabled: !_isLoading,
            required: true,
          ),
          const SizedBox(height: 16),

          WebDropdownField<MachineStatus>(
            label: 'Status',
            value: _status,
            items: _statusItems,
            enabled: !_isLoading,
            required: true,
            onChanged: (v) {
              if (v != null) setState(() => _status = v);
            },
          ),
          const SizedBox(height: 24),

          ReadOnlySection(
            sectionTitle: 'Additional Information',
            fields: [
              ReadOnlyField(
                label: 'Machine ID',
                value: machine.machineId,
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
        ],
      ),
      actions: [
        DialogAction.secondary(
          label: 'Cancel',
          onPressed: _isLoading ? null : _cancel,
        ),
        DialogAction.primary(
          label: 'Save',
          onPressed: _save,
          isLoading: _isLoading,
          isDisabled: !_hasChanges,
        ),
      ],
    );
  }
}