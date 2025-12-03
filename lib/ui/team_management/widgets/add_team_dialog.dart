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
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSaving = ref.watch(
      teamManagementProvider.select((s) => s.isSavingTeams),
    );

    return AlertDialog(
      title: Text("Add Team"),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomTextField(
              labelText: "Team Name",
              hintText: "Team Name",
              prefixIcon: Icons.group,
              controller: nameController,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return "Please enter a team name.";
                }
                return null;
              },
            ),
            SizedBox(height: 10),
            CustomTextField(
              labelText: "Address",
              hintText: "Address",
              prefixIcon: Icons.location_on,
              controller: addressController,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return "Please enter a team name.";
                }
                return null;
              },
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
