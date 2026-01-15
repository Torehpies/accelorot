import 'package:flutter/material.dart';
import 'package:flutter_application_1/frontend/widgets/custom_text_field.dart';
import 'package:flutter_application_1/ui/core/themes/app_theme.dart';
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
  final nameController = TextEditingController();
  final addressController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    addressController.dispose();
    super.dispose();
  }

  void _addTeam() {
    if (_formKey.currentState!.validate()) {
      ref
          .read(teamManagementProvider.notifier)
          .addTeam(nameController.text, addressController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(teamManagementProvider);
    final isSaving = state.isSavingTeams;
    final errorMessage = state.message;

    ref.listen(teamManagementProvider, (previous, next) {
      if (next.isSavingTeams == false &&
          previous?.isSavingTeams == true &&
          (next.message is SuccessMessage)) {
        if (context.mounted) {
          Navigator.pop(context);
        }
      }
    });
    return AlertDialog(
      title: Text("Add Team", style: TextStyle(fontWeight: FontWeight.bold)),
      content: Form(
        key: _formKey,
        child: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
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
              CustomTextField(
                enabled: !isSaving,
                labelText: "Team Name",
                prefixIcon: Icons.group,
                controller: nameController,
                autoFocus: true,
                validator: (value) {
                  final trimmed = value?.trim();
                  if (trimmed == null || trimmed.isEmpty) {
                    return "Please enter a team name.";
                  }
                  if (trimmed.length < 3) {
                    return "Team name must be at least 3 characters.";
                  }
                  return null;
                },
                textInputAction: TextInputAction.next,
              ),
              SizedBox(height: 10),
              CustomTextField(
                enabled: !isSaving,
                onFieldSubmitted: (value) => isSaving ? null : _addTeam(),
                autoFocus: true,
                labelText: "Address",
                prefixIcon: Icons.location_on,
                controller: addressController,
                keyboardType: TextInputType.streetAddress,
                validator: (value) {
                  final trimmed = value?.trim();
                  if (trimmed == null || trimmed.isEmpty) {
                    return "Please enter an address.";
                  }
                  if (trimmed.length < 20) {
                    return "Address name must be at least 20 characters.";
                  }
                  return null;
                },
                textInputAction: TextInputAction.done,
              ),
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
}
