// lib/ui/machine_management/dialogs/web_admin_add_dialog.dart

import 'package:flutter/material.dart';
import '../../../data/models/machine_model.dart';
import '../../core/widgets/dialog/base_dialog.dart';
import '../../core/widgets/dialog/dialog_action.dart';
import '../../core/widgets/dialog/dialog_fields.dart';
import '../../core/widgets/dialog/web_confirmation_dialog.dart';
import '../../core/ui/app_snackbar.dart';

class WebAdminAddDialog extends StatefulWidget {
  final List<MachineModel> machines;
  final Future<void> Function({
    required String machineId,
    required String machineName,
  }) onCreate;

  const WebAdminAddDialog({
    super.key,
    required this.machines,
    required this.onCreate,
  });

  @override
  State<WebAdminAddDialog> createState() => _WebAdminAddDialogState();
}

class _WebAdminAddDialogState extends State<WebAdminAddDialog> {
  final _nameController = TextEditingController();
  bool _isSubmitting = false;
  String? _nameError;

  late final String _generatedId;

  @override
  void initState() {
    super.initState();
    _generatedId = _generateNextMachineId(widget.machines);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  // Scans existing machines for MACH### pattern, returns next ID.
  // Skips gaps — always increments from the highest found.
  // Falls back to MACH001 if none exist.
  String _generateNextMachineId(List<MachineModel> machines) {
    final pattern = RegExp(r'^MACH(\d{3})$');
    int highest = 0;

    for (final machine in machines) {
      final match = pattern.firstMatch(machine.machineId);
      if (match != null) {
        final number = int.tryParse(match.group(1)!) ?? 0;
        if (number > highest) highest = number;
      }
    }

    final next = highest + 1;
    return 'MACH${next.toString().padLeft(3, '0')}';
  }

  bool get _hasValidInput => _nameController.text.trim().isNotEmpty;

  bool _validate() {
    setState(() => _nameError = null);
    if (_nameController.text.trim().isEmpty) {
      setState(() => _nameError = 'Machine name cannot be empty');
      return false;
    }
    return true;
  }

  // ── Cancel handler
  Future<void> _handleCancel() async {
    if (_hasValidInput) {
      final result = await WebConfirmationDialog.show(
        context,
        title: 'Discard Changes',
        message: 'Are you sure you want to discard this new machine?',
        confirmLabel: 'Discard',
        cancelLabel: 'Keep Editing',
        confirmIsDestructive: true,
      );
      if (result == ConfirmResult.confirmed && context.mounted) {
        Navigator.of(context).pop();
      }
    } else {
      Navigator.of(context).pop();
    }
  }

  // ── Submit handler
  Future<void> _handleSubmit() async {
    if (!_validate()) return;

    final result = await WebConfirmationDialog.show(
      context,
      title: 'Create Machine',
      message: 'Are you sure you want to create machine $_generatedId?',
      confirmLabel: 'Create Machine',
      cancelLabel: 'Go Back',
      confirmIsDestructive: false,
    );

    if (result != ConfirmResult.confirmed) return;
    if (!context.mounted) return;

    setState(() => _isSubmitting = true);

    try {
      await widget.onCreate(
        machineId: _generatedId,
        machineName: _nameController.text.trim(),
      );

      if (!mounted) return;
      Navigator.of(context).pop();
      AppSnackbar.success(context, 'Machine created successfully');
    } catch (e) {
      if (!mounted) return;
      AppSnackbar.error(context, 'Failed to create machine');
      setState(() => _isSubmitting = false);
    }
  }

  // ── Build
  @override
  Widget build(BuildContext context) {
    return BaseDialog(
      title: 'Add New Machine',
      subtitle: 'Create a new machine entry',
      canClose: !_isSubmitting,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InputField(
            label: 'Machine Name',
            controller: _nameController,
            hintText: 'Enter machine name',
            errorText: _nameError,
            enabled: !_isSubmitting,
            required: true,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 24),

          ReadOnlySection(
            sectionTitle: 'Additional Information',
            fields: [
              ReadOnlyField(
                label: 'Machine ID',
                value: _generatedId,
              ),
            ],
          ),
        ],
      ),
      actions: [
        // ── Cancel
        DialogAction.secondary(
          label: 'Cancel',
          onPressed: _isSubmitting ? null : _handleCancel,
        ),

        // ── Submit
        DialogAction.primary(
          label: 'Create Machine',
          onPressed: _handleSubmit,
          isLoading: _isSubmitting,
          isDisabled: !_hasValidInput || _nameError != null,
        ),
      ],
    );
  }
}