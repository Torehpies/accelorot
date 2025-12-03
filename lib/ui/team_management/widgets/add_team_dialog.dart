import 'package:flutter/material.dart';
import 'package:flutter_application_1/frontend/widgets/custom_text_field.dart';
import 'package:flutter_application_1/ui/team_management/view_model/team_management_notifier.dart';
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
    final errorMessage = state.errorMessage;

    ref.listen<String?>(
      teamManagementProvider.select((s) => s.successMessage),
      (previous, next) {
        if (next != null) {
          Navigator.of(context).pop();
        }
      },
    );

    ref.listen<String?>(teamManagementProvider.select((s) => s.errorMessage), (
      previous,
      next,
    ) {
      if (next != null) {
        Future.delayed(Duration(seconds: 5), () {
          ref.read(teamManagementProvider.notifier).clearError();
        });
      }
    });
    return AlertDialog(
      title: Text("Add Team"),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: Text(
                  errorMessage,
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

            CustomTextField(
              labelText: "Team Name",
              prefixIcon: Icons.group,
              controller: nameController,
              autoFocus: true,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return "Please enter a team name.";
                }
                return null;
              },
              textInputAction: TextInputAction.next,
            ),
            SizedBox(height: 10),
            CustomTextField(
              onFieldSubmitted: (value) => isSaving ? null : _addTeam(),
              autoFocus: true,
              labelText: "Address",
              prefixIcon: Icons.location_on,
              controller: addressController,
              keyboardType: TextInputType.streetAddress,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return "Please enter a team name.";
                }
                return null;
              },
              textInputAction: TextInputAction.done,
            ),
          ],
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
