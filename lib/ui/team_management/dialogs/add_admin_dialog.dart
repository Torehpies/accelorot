// lib/ui/team_management/dialogs/add_admin_dialog.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_application_1/ui/core/ui/app_snackbar.dart';
import 'package:flutter_application_1/ui/core/widgets/dialog/base_dialog.dart';
import 'package:flutter_application_1/ui/core/widgets/dialog/dialog_action.dart';
import 'package:flutter_application_1/ui/core/widgets/dialog/web_confirmation_dialog.dart';
import 'package:flutter_application_1/ui/core/widgets/fields/name_email_input_fields.dart';
import 'package:flutter_application_1/ui/team_management/view_model/add_admin_notifier.dart';
import 'package:flutter_application_1/ui/team_management/view_model/team_detail_notifier.dart';

class AddAdminDialog extends ConsumerStatefulWidget {
  final String teamId;

  const AddAdminDialog({super.key, required this.teamId});

  @override
  ConsumerState<AddAdminDialog> createState() => _AddAdminDialogState();
}

class _AddAdminDialogState extends ConsumerState<AddAdminDialog> {
  // ── Controllers
  final _firstnameController = TextEditingController();
  final _lastnameController = TextEditingController();
  final _emailController = TextEditingController();

  // ── Field error state
  String? _firstNameError;
  String? _lastNameError;
  String? _emailSubmitError;

  // ── Derived helpers
  bool get _isDirty =>
      _firstnameController.text.isNotEmpty ||
      _lastnameController.text.isNotEmpty ||
      _emailController.text.isNotEmpty;

  bool get _hasValidInput =>
      _firstnameController.text.isNotEmpty &&
      _lastnameController.text.isNotEmpty &&
      EmailInputField.isValid(_emailController.text);

  bool get _hasAnyError =>
      _firstNameError != null ||
      _lastNameError != null ||
      _emailSubmitError != null;

  // ── Submit-time validation
  bool _validate() {
    setState(() {
      _firstNameError = NameInputField.validate(
        _firstnameController.text,
        fieldLabel: 'First name',
      );
      _lastNameError = NameInputField.validate(
        _lastnameController.text,
        fieldLabel: 'Last name',
      );
      _emailSubmitError = _emailController.text.trim().isEmpty
          ? 'Email is required'
          : null;
    });

    return _firstNameError == null &&
        _lastNameError == null &&
        _emailSubmitError == null;
  }

  // ── Cancel handler
  Future<void> _handleCancel() async {
    if (_isDirty) {
      final result = await WebConfirmationDialog.show(
        context,
        title: 'Discard Changes',
        message: 'You have unsaved changes. Are you sure you want to discard them?',
        confirmLabel: 'Discard',
        cancelLabel: 'Keep Editing',
        confirmIsDestructive: true,
      );
      if (result == ConfirmResult.confirmed && context.mounted) {
        // ignore: use_build_context_synchronously
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
      title: 'Add Admin',
      message:
          'Are you sure you want to add this admin? An invitation will be sent to their email.',
      confirmLabel: 'Add Admin',
      cancelLabel: 'Go Back',
      confirmIsDestructive: false,
    );

    if (result != ConfirmResult.confirmed) return;
    if (!context.mounted) return;

    await ref
        .read(addAdminProvider.notifier)
        .addAdmin(
          email: _emailController.text.trim(),
          firstname: _firstnameController.text.trim(),
          lastname: _lastnameController.text.trim(),
          teamId: widget.teamId,
        );

    if (!mounted) return;
    ref.read(teamDetailProvider(widget.teamId).notifier).refresh();
  }

  // ── Lifecycle
  @override
  void dispose() {
    _firstnameController.dispose();
    _lastnameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  // ── Build
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(addAdminProvider);

    ref.listen(addAdminProvider, (previous, next) {
      if (previous?.isLoading == true && next.isLoading == false) {
        if (next.admin != null) {
          if (context.mounted) {
            Navigator.of(context).pop();
            AppSnackbar.success(context, 'Admin added successfully!');
          }
        } else if (next.error != null) {
          if (context.mounted) {
            AppSnackbar.error(context, next.error!);
          }
        }
      }
    });

    return BaseDialog(
      title: 'Add Admin',
      subtitle: 'Fill in the details below to add a new admin.',
      canClose: !state.isLoading,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── First Name
          NameInputField(
            label: 'First Name',
            controller: _firstnameController,
            hintText: 'Enter first name',
            errorText: _firstNameError,
            enabled: !state.isLoading,
            onChanged: (_) => setState(() => _firstNameError = null),
          ),
          const SizedBox(height: 16),

          // ── Last Name
          NameInputField(
            label: 'Last Name',
            controller: _lastnameController,
            hintText: 'Enter last name',
            errorText: _lastNameError,
            enabled: !state.isLoading,
            onChanged: (_) => setState(() => _lastNameError = null),
          ),
          const SizedBox(height: 16),

          // ── Email
          EmailInputField(
            controller: _emailController,
            enabled: !state.isLoading,
            submitError: _emailSubmitError,
            onChanged: (_) => setState(() => _emailSubmitError = null),
          ),
        ],
      ),
      actions: [
        // ── Cancel
        DialogAction.secondary(
          label: 'Cancel',
          onPressed: state.isLoading ? null : _handleCancel,
        ),

        // ── Submit
        DialogAction.primary(
          label: 'Add Admin',
          onPressed: _handleSubmit,
          isLoading: state.isLoading,
          isDisabled: !_hasValidInput || _hasAnyError,
        ),
      ],
    );
  }
}