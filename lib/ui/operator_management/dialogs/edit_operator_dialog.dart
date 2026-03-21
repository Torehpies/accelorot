// lib/ui/operator_management/dialogs/edit_operator_dialog.dart

import 'package:flutter/material.dart';
import 'package:flutter_application_1/data/services/api/model/team_member/team_member.dart';
import 'package:flutter_application_1/ui/core/widgets/dialog/base_dialog.dart';
import 'package:flutter_application_1/ui/core/widgets/dialog/dialog_action.dart';
import 'package:flutter_application_1/ui/core/widgets/dialog/dialog_fields.dart';
import 'package:flutter_application_1/ui/core/widgets/dialog/web_confirmation_dialog.dart';
import 'package:flutter_application_1/ui/core/widgets/fields/name_email_input_fields.dart';
import 'package:flutter_application_1/utils/format.dart';
import 'package:flutter_application_1/utils/user_status.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'edit_operator_dialog.freezed.dart';

// ── Form model

@freezed
abstract class EditOperatorForm with _$EditOperatorForm {
  const factory EditOperatorForm({
    required String id,
    required String firstName,
    required String lastName,
    required String email,
    @Default(UserStatus.active) UserStatus status,
  }) = _EditOperatorForm;

  factory EditOperatorForm.fromOperator(TeamMember operator) => EditOperatorForm(
        id: operator.id,
        firstName: operator.firstName,
        lastName: operator.lastName,
        email: operator.email,
        status: operator.status,
      );
}

// ── Dialog

class EditOperatorDialog extends StatefulWidget {
  final TeamMember operator;
  final Function(EditOperatorForm) onSave;

  const EditOperatorDialog({
    super.key,
    required this.operator,
    required this.onSave,
  });

  @override
  State<EditOperatorDialog> createState() => _EditOperatorDialogState();
}

class _EditOperatorDialogState extends State<EditOperatorDialog> {
  // ── Controllers
  late final TextEditingController _firstnameController;
  late final TextEditingController _lastnameController;
  late UserStatus _status;

  // ── Field error state
  String? _firstNameError;
  String? _lastNameError;

  bool _isLoading = false;

  static const _statusItems = [
    DropdownItem(value: UserStatus.active, label: 'Active'),
    DropdownItem(value: UserStatus.archived, label: 'Archived'),
    DropdownItem(value: UserStatus.removed, label: 'Removed'),
  ];

  @override
  void initState() {
    super.initState();
    _firstnameController = TextEditingController(text: widget.operator.firstName);
    _lastnameController = TextEditingController(text: widget.operator.lastName);
    _status = widget.operator.status;
  }

  @override
  void dispose() {
    _firstnameController.dispose();
    _lastnameController.dispose();
    super.dispose();
  }

  // ── Derived helpers
  bool get _hasChanges =>
      _firstnameController.text.trim() != widget.operator.firstName ||
      _lastnameController.text.trim() != widget.operator.lastName ||
      _status != widget.operator.status;

  bool get _hasAnyError => _firstNameError != null || _lastNameError != null;

  // ── Validation
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
    });
    return _firstNameError == null && _lastNameError == null;
  }

  // ── Cancel handler
  Future<void> _handleCancel() async {
    if (_hasChanges) {
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

  // ── Save handler
  Future<void> _handleSave() async {
    if (!_validate()) return;

    final result = await WebConfirmationDialog.show(
      context,
      title: 'Save Changes',
      message: 'Are you sure you want to save these changes?',
      confirmLabel: 'Save Changes',
      cancelLabel: 'Go Back',
      confirmIsDestructive: false,
    );

    if (result != ConfirmResult.confirmed) return;
    if (!context.mounted) return;

    setState(() => _isLoading = true);

    final form = EditOperatorForm(
      id: widget.operator.id,
      firstName: _firstnameController.text.trim(),
      lastName: _lastnameController.text.trim(),
      email: widget.operator.email,
      status: _status,
    );

    widget.onSave(form);

    if (!mounted) return;
    Navigator.of(context).pop();
  }

  // ── Build
  @override
  Widget build(BuildContext context) {
    return BaseDialog(
      title: '${widget.operator.firstName} ${widget.operator.lastName}',
      subtitle: 'Edit Operator',
      canClose: !_isLoading,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── First Name
          NameInputField(
            label: 'First Name',
            controller: _firstnameController,
            hintText: 'Enter first name',
            errorText: _firstNameError,
            enabled: !_isLoading,
            onChanged: (_) => setState(() => _firstNameError = null),
          ),
          const SizedBox(height: 16),

          // ── Last Name
          NameInputField(
            label: 'Last Name',
            controller: _lastnameController,
            hintText: 'Enter last name',
            errorText: _lastNameError,
            enabled: !_isLoading,
            onChanged: (_) => setState(() => _lastNameError = null),
          ),
          const SizedBox(height: 16),

          // ── Status
          WebDropdownField<UserStatus>(
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
                label: 'Email',
                value: widget.operator.email,
              ),
              ReadOnlyField(
                label: 'Operator ID',
                value: widget.operator.id,
              ),
              ReadOnlyField(
                label: 'Added At',
                value: formatDateAndTime(widget.operator.addedAt),
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
          isDisabled: !_hasChanges || _hasAnyError,
        ),
      ],
    );
  }
}