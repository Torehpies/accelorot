import 'package:flutter/material.dart';
import 'package:flutter_application_1/ui/core/widgets/operator_dialog_shell.dart';
import 'package:flutter_application_1/data/services/api/model/team_member/team_member.dart';
import 'package:flutter_application_1/ui/core/themes/app_theme.dart';
import 'package:flutter_application_1/ui/core/ui/confirm_dialog.dart';
import 'package:flutter_application_1/utils/user_status.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'edit_operator_dialog.freezed.dart';

@freezed
abstract class EditOperatorForm with _$EditOperatorForm {
  const factory EditOperatorForm({
    required String id,
    required String firstName,
    required String lastName,
    required String email,
    @Default(UserStatus.active) UserStatus status,
  }) = _EditOperatorForm;

  factory EditOperatorForm.fromOperator(TeamMember operator) =>
      EditOperatorForm(
        firstName: operator.firstName,
        lastName: operator.lastName,
        email: operator.email,
        status: operator.status,
        id: operator.id,
      );
}

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
  late EditOperatorForm form = EditOperatorForm.fromOperator(widget.operator);
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return OperatorDialogShell(
      title: const Text(
        'Edit Operator',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Update the operator account that manages machine operations and maintenance.',
          ),
          const Divider(thickness: 1, height: 24),
          const SizedBox(height: 5),
          Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  initialValue: form.firstName,
                  decoration: const InputDecoration(labelText: 'First Name'),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Required' : null,
                  onChanged: (value) {
                    setState(() {
                      form = form.copyWith(firstName: value);
                    });
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  initialValue: form.lastName,
                  decoration: const InputDecoration(labelText: 'Last Name'),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Required' : null,
                  onChanged: (value) {
                    setState(() {
                      form = form.copyWith(lastName: value);
                    });
                  },
                ),
                const SizedBox(height: 20),

                // Email: visible, but not editable
                TextFormField(
                  initialValue: form.email,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    filled: true,
                  ),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 20),

                DropdownButtonFormField<UserStatus>(
                  initialValue: form.status,
                  decoration: const InputDecoration(labelText: 'Status'),
                  items:
                      const [
                            UserStatus.active,
                            UserStatus.archived,
                            UserStatus.removed,
                          ]
                          .map(
                            (status) => DropdownMenuItem<UserStatus>(
                              value: status,
                              child: Text(switch (status) {
                                UserStatus.active => 'Active',
                                UserStatus.archived => 'Archive',
                                UserStatus.removed => 'Remove',
                                _ => status.value,
                              }),
                            ),
                          )
                          .toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() {
                      form = form.copyWith(status: value);
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(onPressed: _save, child: const Text('Confirm')),
      ],
    );
  }

  void _save() async {
    final navigator = Navigator.of(context);
    final formKeyState = _formKey.currentState;

    final confirmed = await showConfirmDialog(
      context: context,
      title: 'Confirm Changes',
      message: 'Are you sure with your changes?',
    );

    if (confirmed == true && formKeyState!.validate() && mounted) {
      navigator.pop(context);
      widget.onSave(form);
    }
  }
}
