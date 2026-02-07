// lib/ui/machine_management/dialogs/web_admin_add_dialog.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/dialog/base_dialog.dart';
import '../../core/dialog/dialog_action.dart';
import '../../core/dialog/dialog_fields.dart';
import '../../core/toast/toast_service.dart';

class WebAdminAddDialog extends StatefulWidget {
  final Future<void> Function({
    required String machineId,
    required String machineName,
  })
  onCreate;

  const WebAdminAddDialog({super.key, required this.onCreate});

  @override
  State<WebAdminAddDialog> createState() => _WebAdminAddDialogState();
}

class _WebAdminAddDialogState extends State<WebAdminAddDialog> {
  final _nameController = TextEditingController();
  final _idController = TextEditingController();
  bool _isSubmitting = false;
  String? _nameError;
  String? _idError;

  @override
  void dispose() {
    _nameController.dispose();
    _idController.dispose();
    super.dispose();
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

  void _validateId() {
    setState(() {
      final id = _idController.text.trim();
      if (id.isEmpty) {
        _idError = 'Machine ID is required';
      } else if (id.contains(' ')) {
        _idError = 'Machine ID cannot contain spaces';
      } else {
        _idError = null;
      }
    });
  }

  Future<void> _handleSubmit() async {
    // Validate both fields
    _validateName();
    _validateId();

    final name = _nameController.text.trim();
    final id = _idController.text.trim();

    // Stop if validation errors
    if (_nameError != null || _idError != null) {
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await widget.onCreate(machineId: id, machineName: name);

      if (!mounted) return;
      Navigator.of(context).pop();
      ToastService.show(context, message: 'Machine created successfully');
    } catch (e) {
      if (!mounted) return;

      // Check for duplicate ID error
      final errorMessage = e.toString();
      if (errorMessage.contains('already exists')) {
        setState(() {
          _idError = 'This Machine ID already exists';
          _isSubmitting = false;
        });
      } else {
        ToastService.show(context, message: 'Failed to create: $e');
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseDialog(
      title: 'Add New Machine',
      subtitle: 'Create a new machine entry',
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
            onChanged: (_) => _validateName(),
          ),
          const SizedBox(height: 16),
          InputField(
            label: 'Machine ID',
            controller: _idController,
            hintText: 'Enter unique machine ID',
            helperText: 'Must be unique and cannot contain spaces',
            errorText: _idError,
            enabled: !_isSubmitting,
            required: true,
            maxLength: 30,
            inputFormatters: [
              FilteringTextInputFormatter.deny(RegExp(r'\s')), // No spaces
            ],
            onChanged: (_) => _validateId(),
          ),
          const SizedBox(height: 16),
          InputField(
            label: 'Assigned Users',
            controller: TextEditingController(text: 'All Team Members'),
            helperText: 'All team members will have access to this machine',
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
          label: 'Create Machine',
          onPressed: _nameError == null && _idError == null && !_isSubmitting
              ? _handleSubmit
              : null,
          isLoading: _isSubmitting,
        ),
      ],
    );
  }
}
