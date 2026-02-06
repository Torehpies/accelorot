// lib/ui/web_operator/bottom_sheets/team_member_edit_sheet.dart

import 'package:flutter/material.dart';
import 'package:flutter_application_1/data/services/api/model/team_member/team_member.dart';
import 'package:flutter_application_1/utils/user_status.dart';
import 'package:flutter_application_1/ui/web_operator/widgets/edit_operator_dialog.dart';
import '../../core/bottom_sheet/mobile_bottom_sheet_base.dart';
import '../../core/bottom_sheet/mobile_bottom_sheet_buttons.dart';
import '../../core/bottom_sheet/fields/mobile_readonly_field.dart';
import '../../core/bottom_sheet/fields/mobile_readonly_section.dart';
import '../../core/bottom_sheet/fields/mobile_input_field.dart';
import '../../core/bottom_sheet/fields/mobile_dropdown_field.dart';
import '../../core/dialog/mobile_confirmation_dialog.dart';
import '../../core/toast/mobile_toast_service.dart';
import '../../core/toast/toast_type.dart';

typedef UpdateTeamMemberCallback = Future<void> Function(EditOperatorForm form);

class TeamMemberEditSheet extends StatefulWidget {
  final TeamMember member;
  final UpdateTeamMemberCallback onUpdate;

  const TeamMemberEditSheet({
    super.key,
    required this.member,
    required this.onUpdate,
  });

  @override
  State<TeamMemberEditSheet> createState() => _TeamMemberEditSheetState();
}

class _TeamMemberEditSheetState extends State<TeamMemberEditSheet> {
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _emailController;
  late UserStatus _status;

  bool _isLoading = false;
  String? _firstNameError;
  String? _lastNameError;
  String? _emailError;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(text: widget.member.firstName);
    _lastNameController = TextEditingController(text: widget.member.lastName);
    _emailController = TextEditingController(text: widget.member.email);
    _status = widget.member.status;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  bool get _hasChanges {
    return _firstNameController.text.trim() != widget.member.firstName.trim() ||
        _lastNameController.text.trim() != widget.member.lastName.trim() ||
        _emailController.text.trim() != widget.member.email.trim() ||
        _status != widget.member.status;
  }

  bool _validate() {
    setState(() {
      _firstNameError = null;
      _lastNameError = null;
      _emailError = null;
    });

    bool isValid = true;

    if (_firstNameController.text.trim().isEmpty) {
      setState(() => _firstNameError = 'First name cannot be empty');
      isValid = false;
    }

    if (_lastNameController.text.trim().isEmpty) {
      setState(() => _lastNameError = 'Last name cannot be empty');
      isValid = false;
    }

    if (_emailController.text.trim().isEmpty) {
      setState(() => _emailError = 'Email cannot be empty');
      isValid = false;
    } else if (!_isValidEmail(_emailController.text.trim())) {
      setState(() => _emailError = 'Invalid email format');
      isValid = false;
    }

    return isValid;
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  Future<void> _save() async {
    if (!_validate()) return;

    setState(() => _isLoading = true);

    try {
      final form = EditOperatorForm(
        id: widget.member.id,
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        email: _emailController.text.trim(),
        status: _status,
      );

      await widget.onUpdate(form);

      if (mounted) {
        MobileToastService.show(
          context,
          message: 'Team member updated successfully',
          type: ToastType.success,
        );
        await Future.delayed(const Duration(milliseconds: 600));
        if (mounted) Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        MobileToastService.show(
          context,
          message: 'Failed to update team member',
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

  static const List<MobileDropdownItem<UserStatus>> _statusItems = [
    MobileDropdownItem(value: UserStatus.active, label: 'Active'),
    MobileDropdownItem(value: UserStatus.removed, label: 'Removed'),
    MobileDropdownItem(value: UserStatus.archived, label: 'Archived'),
  ];

  String _formatDateTime(DateTime dt) {
    final months = [
      'Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec',
    ];
    final h = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    final min = dt.minute.toString().padLeft(2, '0');
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}  $h:$min $ampm';
  }

  @override
  Widget build(BuildContext context) {
    return MobileBottomSheetBase(
      title: '${widget.member.lastName}, ${widget.member.firstName}',
      subtitle: 'Edit Team Member',
      showCloseButton: false,
      actions: [
        BottomSheetAction.secondary(
          label: 'Cancel',
          onPressed: _cancel,
        ),
        BottomSheetAction.primary(
          label: 'Save',
          onPressed: _save,
          isLoading: _isLoading,
          isDisabled: !_hasChanges,
        ),
      ],
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MobileInputField(
            label: 'First Name',
            controller: _firstNameController,
            required: true,
            errorText: _firstNameError,
            hintText: 'Enter first name',
          ),
          const SizedBox(height: 16),

          MobileInputField(
            label: 'Last Name',
            controller: _lastNameController,
            required: true,
            errorText: _lastNameError,
            hintText: 'Enter last name',
          ),
          const SizedBox(height: 16),

          MobileInputField(
            label: 'Email',
            controller: _emailController,
            required: true,
            errorText: _emailError,
            hintText: 'Enter email',
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),

          MobileDropdownField<UserStatus>(
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
                label: 'Member ID',
                value: widget.member.id,
              ),
              MobileReadOnlyField(
                label: 'Created',
                value: _formatDateTime(widget.member.addedAt),
              ),
            ],
          ),
        ],
      ),
    );
  }
}