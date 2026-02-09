// lib/ui/machine_management/dialogs/web_admin_edit_dialog.dart

import 'package:flutter/material.dart';
import '../../../data/models/machine_model.dart';
import '../../core/widgets/dialog/base_dialog.dart';
import '../../core/widgets/dialog/dialog_action.dart';
import '../../core/widgets/dialog/dialog_fields.dart';
import '../../core/ui/app_snackbar.dart';

class WebAdminEditDialog extends StatefulWidget {
  final MachineModel machine;
  final Future<void> Function({
    required String machineId,
    required String machineName,
  })
  onUpdate;

  const WebAdminEditDialog({
    super.key,
    required this.machine,
    required this.onUpdate,
  });

  @override
  State<WebAdminEditDialog> createState() => _WebAdminEditDialogState();
}

class _WebAdminEditDialogState extends State<WebAdminEditDialog> {
  late final TextEditingController _nameController;
  bool _isSubmitting = false;
  String? _nameError;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.machine.machineName);
    _nameController.addListener(_validateName);
  }

  @override
  void dispose() {
    _nameController.removeListener(_validateName);
    _nameController.dispose();
    super.dispose();
  }

  bool get _hasChanges {
    return _nameController.text.trim() != widget.machine.machineName;
  }

  void _validateName() {
    setState(() {
      final name = _nameController.text.trim();
      if (name.isEmpty) {
        _nameError = 'Machine name is required';
      } else {
        _nameError = null;
      }
    });
  }

  Future<void> _handleSubmit() async {
    final name = _nameController.text.trim();

    // Validate
    if (name.isEmpty) {
      setState(() => _nameError = 'Machine name is required');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await widget.onUpdate(
        machineId: widget.machine.machineId,
        machineName: name,
      );

      if (!mounted) return;
      Navigator.of(context).pop();
      AppSnackbar.success(context, 'Machine updated successfully');
    } catch (e) {
      if (!mounted) return;
      AppSnackbar.error(context, 'Failed to update: $e');
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseDialog(
      title: 'Edit Machine',
      subtitle: 'Update machine details',
      maxHeightFactor: 0.65,
      canClose: !_isSubmitting,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InputField(
            label: 'Machine Name',
            controller: _nameController,
            hintText: 'Enter machine name',
            errorText: _nameError,
            enabled: !_isSubmitting,
            required: true,
            maxLength: 50,
          ),
          const SizedBox(height: 16),
          InputField(
            label: 'Machine ID',
            controller: TextEditingController(text: widget.machine.machineId),
            helperText: 'Machine ID cannot be changed',
            enabled: false,
          ),
          const SizedBox(height: 16),
          InputField(
            label: 'Assigned Users',
            controller: TextEditingController(text: 'All Team Members'),
            helperText: 'All team members have access to this machine',
            enabled: false,
          ),
        ],
      ),
      actions: [
        DialogAction.secondary(
          label: 'Cancel',
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
        ),
        DialogAction.primary(
          label: 'Update Machine',
          onPressed: _handleSubmit,
          isLoading: _isSubmitting,
          isDisabled: !_hasChanges || _nameError != null,
        ),
      ],
    );
  }
}