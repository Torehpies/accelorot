// lib/ui/machine_management/dialogs/web_admin_add_dialog.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/widgets/dialog/base_dialog.dart';
import '../../core/widgets/dialog/dialog_action.dart';
import '../../core/widgets/dialog/dialog_fields.dart';
import '../../core/ui/app_snackbar.dart';

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

  bool get _hasValidInput {
    final name = _nameController.text.trim();
    final id = _idController.text.trim();
    
    return name.isNotEmpty && 
           id.isNotEmpty && 
           RegExp(r'^[a-zA-Z0-9]+$').hasMatch(id);
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
      } else if (!RegExp(r'^[a-zA-Z0-9]+$').hasMatch(id)) {
        _idError = 'Only letters and numbers allowed';
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
      AppSnackbar.success(context, 'Machine created successfully');
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
        AppSnackbar.error(context, 'Failed to create: $e');
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
            helperText: 'Max 30 characters. Letters and numbers only',
            errorText: _idError,
            enabled: !_isSubmitting,
            required: true,
            maxLength: 30,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
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
          onPressed: _handleSubmit,
          isLoading: _isSubmitting,
          isDisabled: !_hasValidInput || _nameError != null || _idError != null,
        ),
      ],
    );
  }
}