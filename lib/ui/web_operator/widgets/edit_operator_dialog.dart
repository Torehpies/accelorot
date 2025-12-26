import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'edit_operator_dialog.freezed.dart';

@freezed
abstract class EditOperatorForm with _$EditOperatorForm {
  const factory EditOperatorForm({
    required String id,
    required String firstName,
    required String lastName,
    required String email,
    @Default('active') String status,
  }) = _EditOperatorForm;

  factory EditOperatorForm.fromOperator(dynamic operator) => EditOperatorForm(
    firstName: operator.firstName,
    lastName: operator.lastName,
    email: operator.email,
    status: operator.status.value,
    id: operator.id,
  );
}

class EditOperatorDialog extends StatefulWidget {
  final dynamic operator;
  final Function(dynamic) onSave;

  const EditOperatorDialog({
    super.key,
    required this.operator,
    required this.onSave,
  });

  @override
  State<EditOperatorDialog> createState() => _EditOperatorDialogState();
}

class _EditOperatorDialogState extends State<EditOperatorDialog> {
  late final form = EditOperatorForm.fromOperator(widget.operator);
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Operator'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              initialValue: form.firstName,
              decoration: const InputDecoration(labelText: 'First Name'),
              validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
              onChanged: (value) =>
                  setState(() => form.copyWith(firstName: value)),
            ),
            TextFormField(
              initialValue: form.lastName,
              decoration: const InputDecoration(labelText: 'Last Name'),
              validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
              onChanged: (value) =>
                  setState(() => form.copyWith(lastName: value)),
            ),
            TextFormField(
              initialValue: form.email,
              decoration: const InputDecoration(labelText: 'Email'),
              validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
              onChanged: (value) => setState(() => form.copyWith(email: value)),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(onPressed: _save, child: const Text('Save')),
      ],
    );
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      Navigator.pop(context);
      widget.onSave(form);
    }
  }
}
