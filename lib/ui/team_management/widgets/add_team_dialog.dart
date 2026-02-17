import 'package:flutter/material.dart';
import 'package:flutter_application_1/ui/core/themes/app_theme.dart';
import 'package:flutter_application_1/ui/core/widgets/dialog_shell.dart';
import 'package:flutter_application_1/ui/team_management/view_model/team_management_notifier.dart';
import 'package:flutter_application_1/utils/ui_message.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddTeamDialog extends ConsumerStatefulWidget {
  const AddTeamDialog({super.key});

  @override
  ConsumerState<AddTeamDialog> createState() => _AddTeamDialogState();
}

class _AddTeamDialogState extends ConsumerState<AddTeamDialog> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(teamManagementProvider);
    final isSaving = state.isSavingTeams;
    final errorMessage = state.message;

    String _teamName = '';
    String _houseNumber = '';
    String _street = '';
    String _barangay = '';
    String _city = '';
    String _region = '';

    ref.listen(teamManagementProvider, (previous, next) {
      if (next.isSavingTeams == false &&
          previous?.isSavingTeams == true &&
          (next.message is SuccessMessage)) {
        if (context.mounted) {
          Navigator.pop(context);
        }
      }
    });
    return DialogShell(
      title: Text("Add Team", style: TextStyle(fontWeight: FontWeight.bold)),
      content: Form(
        key: _formKey,
        child: SizedBox(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Create new team'),
              const Divider(thickness: 1, height: 24),
              const SizedBox(height: 5),
              if (errorMessage != null && errorMessage is ErrorMessage)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error, color: AppColors.error),
                      SizedBox(width: 5),
                      Text(
                        errorMessage.text,
                        style: const TextStyle(
                          color: AppColors.error,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              TextFormField(
                autovalidateMode: AutovalidateMode.onUserInteraction,
                decoration: InputDecoration(
                  hintText: 'Team',
                  labelText: 'Team Name',
                ),
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? 'Team Name is required'
                    : (value.trim().length < 3)
                    ? 'Team name must be at least 3 characters'
                    : null,
                enabled: !isSaving,
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.text,
                onSaved: (value) => _teamName = value!.trim(),
              ),
              SizedBox(height: 10),
              TextFormField(
                autovalidateMode: AutovalidateMode.onUserInteraction,
                decoration: InputDecoration(
                  hintText: '1111 / Lot 10 Blk 10',
                  labelText: 'House/Lot/Block',
                ),
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? 'This field is required'
                    : (value.trim().length < 3)
                    ? 'This field must be at least 4 characters'
                    : null,
                enabled: !isSaving,
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.streetAddress,
                onSaved: (value) => _houseNumber = value!.trim(),
              ),
              SizedBox(height: 10),
              TextFormField(
                autovalidateMode: AutovalidateMode.onUserInteraction,
                decoration: InputDecoration(
                  hintText: 'Libra St. / Zabarte Road / Luisa Subd.',
                  labelText: 'Street/Road/Subd.',
                ),
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? 'This field is required'
                    : (value.trim().length < 4)
                    ? 'This field must be at least 4 characters'
                    : null,
                enabled: !isSaving,
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.streetAddress,
                onSaved: (value) => _street = value!.trim(),
              ),
              SizedBox(height: 10),
              TextFormField(
                autovalidateMode: AutovalidateMode.onUserInteraction,
                decoration: InputDecoration(
                  hintText: '178 / 176-E',
                  labelText: 'Barangay',
                ),
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? 'This field is required'
                    : (value.trim().length > 5)
                    ? 'This field has a maximum of 5 characters'
                    : null,
                enabled: !isSaving,
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.text,
                onSaved: (value) => _barangay = value!.trim(),
              ),
              SizedBox(height: 10),
              TextFormField(
                autovalidateMode: AutovalidateMode.onUserInteraction,
                decoration: InputDecoration(
                  hintText: 'Caloocan City',
                  labelText: 'City',
                ),
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? 'This field is required'
                    : (value.trim().length < 4)
                    ? 'This field must be at least 4 characters'
                    : null,
                enabled: !isSaving,
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.text,
                onSaved: (value) => _city = value!.trim(),
              ),
              SizedBox(height: 10),
              TextFormField(
                autovalidateMode: AutovalidateMode.onUserInteraction,
                decoration: InputDecoration(
                  hintText: 'Region 1 / NCR',
                  labelText: 'Region',
                ),
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? 'This field is required'
                    : (value.trim().length < 3)
                    ? 'This field must be at least 3 characters'
                    : null,
                enabled: !isSaving,
                textInputAction: TextInputAction.done,
                keyboardType: TextInputType.text,
                onSaved: (value) => _region = value!.trim(),
              ),
              SizedBox(height: 10),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: isSaving ? null : () => Navigator.pop(context),
          child: Text("Cancel"),
        ),
        ElevatedButton.icon(
          onPressed: isSaving ? null : _addTeam,
          icon: isSaving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.add),
          label: Text(isSaving ? "Saving..." : "Add Team"),
        ),
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _addTeam() {
    if (_formKey.currentState!.validate()) {
      ref.read(teamManagementProvider.notifier).addTeam("chan", "TODO");
    }
  }
}
