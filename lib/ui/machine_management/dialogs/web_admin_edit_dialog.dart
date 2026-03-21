// lib/ui/machine_management/dialogs/web_admin_edit_dialog.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/models/machine_model.dart';
import '../../core/widgets/dialog/base_dialog.dart';
import '../../core/widgets/dialog/dialog_action.dart';
import '../../core/widgets/dialog/dialog_fields.dart';
import '../../core/widgets/dialog/web_confirmation_dialog.dart';
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

  static const List<DropdownItem<MachineStatus>> _statusItems = [
    DropdownItem(value: MachineStatus.active, label: 'Active'),
    DropdownItem(value: MachineStatus.inactive, label: 'Inactive'),
    DropdownItem(value: MachineStatus.underMaintenance, label: 'Suspended'),
  ];

  @override
  void initState() {
    super.initState();
    _machineNameController = TextEditingController(text: widget.machine.machineName);
    _status = widget.machine.status;
  }

  @override
  void dispose() {
    _machineNameController.dispose();
    super.dispose();
  }

  // ── Derived helpers
  bool get _hasChanges =>
      _machineNameController.text.trim() != widget.machine.machineName.trim() ||
      _status != widget.machine.status;

  bool _validate() {
    setState(() => _machineNameError = null);
    if (_machineNameController.text.trim().isEmpty) {
      setState(() => _machineNameError = 'Machine name cannot be empty');
      return false;
    }
    return true;
  }

  // ── Cancel handler
  Future<void> _handleCancel() async {
    if (_hasChanges) {
      final result = await WebConfirmationDialog.show(context);
      if (result == ConfirmResult.confirmed && context.mounted) {
        Navigator.of(context).pop();
      }
    } else {
      Navigator.of(context).pop();
    }
  }

  // ── Save handler
  Future<void> _handleSave() async {
    if (!_validate()) return;

    final result = await WebConfirmationDialog.show(
      context,
      title: 'Save Changes',
      message: 'Are you sure you want to save changes to ${widget.machine.machineName}?',
      confirmLabel: 'Save Changes',
      cancelLabel: 'Go Back',
      confirmIsDestructive: false,
    );

    if (result != ConfirmResult.confirmed) return;
    if (!context.mounted) return;

    setState(() => _isLoading = true);

    try {
      await widget.onUpdate(
        machineId: widget.machine.machineId,
        machineName: _machineNameController.text.trim(),
        status: _status,
      );

      if (!mounted) return;
      Navigator.of(context).pop();
      AppSnackbar.success(context, 'Machine updated successfully');
    } catch (e) {
      if (!mounted) return;
      AppSnackbar.error(context, 'Failed to update machine');
      setState(() => _isLoading = false);
    }
  }

  // ── Build
  @override
  Widget build(BuildContext context) {
    return BaseDialog(
      title: widget.machine.machineName,
      subtitle: 'Edit Machine',
      canClose: !_isLoading,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Machine Name
          InputField(
            label: 'Machine Name',
            controller: _machineNameController,
            hintText: 'Enter machine name',
            errorText: _machineNameError,
            enabled: !_isLoading,
            required: true,
            onChanged: (_) => setState(() => _machineNameError = null),
          ),
          const SizedBox(height: 16),

          // ── Status
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

          // ── Read-only info
          ReadOnlySection(
            sectionTitle: 'Additional Information',
            fields: [
              ReadOnlyField(
                label: 'Machine ID',
                value: widget.machine.machineId,
              ),
              ReadOnlyField(
                label: 'Current Batch',
                value: widget.machine.currentBatchId ?? 'No active batch',
              ),
              ReadOnlyField(
                label: 'Date Created',
                value: DateFormat('MMM dd, yyyy').format(widget.machine.dateCreated),
              ),
              ReadOnlyField(
                label: 'Last Modified',
                value: widget.machine.lastModified != null
                    ? DateFormat('MMM dd, yyyy').format(widget.machine.lastModified!)
                    : 'Never',
              ),
            ],
          ),
        ],
      ),
      actions: [
        // ── Cancel
        DialogAction.secondary(
          label: 'Cancel',
          onPressed: _isLoading ? null : _handleCancel,
        ),

        // ── Save
        DialogAction.primary(
          label: 'Save Changes',
          onPressed: _handleSave,
          isLoading: _isLoading,
          isDisabled: !_hasChanges,
        ),
      ],
    );
  }
}