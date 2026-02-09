// lib/ui/machine_management/bottom_sheets/mobile_admin_machine_add_sheet.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/widgets/bottom_sheets/mobile_bottom_sheet_base.dart';
import '../../core/widgets/bottom_sheets/mobile_bottom_sheet_buttons.dart';
import '../../core/widgets/bottom_sheets/fields/mobile_input_field.dart';
import '../../core/ui/app_snackbar.dart';

typedef CreateMachineCallback = Future<void> Function({
  required String machineId,
  required String machineName,
});

class MobileAdminMachineAddSheet extends StatefulWidget {
  final String teamId;
  final CreateMachineCallback onCreate;

  const MobileAdminMachineAddSheet({
    super.key,
    required this.teamId,
    required this.onCreate,
  });

  @override
  State<MobileAdminMachineAddSheet> createState() =>
      _MobileAdminMachineAddSheetState();
}

class _MobileAdminMachineAddSheetState
    extends State<MobileAdminMachineAddSheet> {
  final _nameController = TextEditingController();
  final _idController = TextEditingController();

  bool _isLoading = false;
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
      } else if (!RegExp(r'^[a-zA-Z0-9]+$').hasMatch(id)) {
        _idError = 'Only letters and numbers allowed';
      } else {
        _idError = null;
      }
    });
  }

  Future<void> _save() async {
    _validateName();
    _validateId();

    final name = _nameController.text.trim();
    final id = _idController.text.trim();

    if (_nameError != null || _idError != null) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      await widget.onCreate(machineId: id, machineName: name);

      if (mounted) {
        Navigator.of(context).pop();
        AppSnackbar.success(context, 'Machine created successfully');
      }
    } catch (e) {
      if (mounted) {
        final errorMessage = e.toString();
        if (errorMessage.contains('already exists')) {
          setState(() {
            _idError = 'This Machine ID already exists';
            _isLoading = false;
          });
        } else {
          setState(() => _isLoading = false);
          AppSnackbar.error(context, 'Failed to create machine');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MobileBottomSheetBase(
      title: 'New Machine',
      subtitle: 'Add Machine',
      showCloseButton: false,
      actions: [
        BottomSheetAction.secondary(
          label: 'Cancel',
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
        ),
        BottomSheetAction.primary(
          label: 'Create Machine',
          onPressed: _isLoading ? null : _save,
          isLoading: _isLoading,
        ),
      ],
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MobileInputField(
            label: 'Machine Name',
            controller: _nameController,
            required: true,
            errorText: _nameError,
            hintText: 'Enter machine name',
            maxLength: 50,
            onChanged: (_) => _validateName(),
          ),
          const SizedBox(height: 16),

          MobileInputField(
            label: 'Machine ID',
            controller: _idController,
            required: true,
            errorText: _idError,
            hintText: 'Enter unique machine ID',
            helperText: 'Max 30 characters. Letters and numbers only',
            maxLength: 30,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
            ],
            onChanged: (_) => _validateId(),
          ),
          const SizedBox(height: 16),

          MobileInputField(
            label: 'Assigned Users',
            controller: TextEditingController(text: 'All Team Members'),
            helperText: 'All team members will have access to this machine',
            enabled: false,
          ),
        ],
      ),
    );
  }
}