import 'package:flutter/material.dart';
import 'package:flutter_application_1/ui/core/widgets/dialog_shell.dart';
import 'package:flutter_application_1/ui/core/widgets/fields/read_only_field.dart';
import 'package:flutter_application_1/utils/format.dart';
import 'package:flutter_application_1/data/services/api/model/team_member/team_member.dart';
import 'package:flutter_application_1/utils/roles.dart';

class ViewMemberDialog extends StatelessWidget {
  final TeamMember member;

  const ViewMemberDialog({super.key, required this.member});

  @override
  Widget build(BuildContext context) {
    final label = member.teamRole == TeamRole.admin ? "Admin" : "Member";
    return DialogShell(
      title: Text(
        '$label Details',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('View in-depth information about this ${label.toLowerCase()}.'),
          const Divider(thickness: 1, height: 24),
          const SizedBox(height: 5),
          _buildDetailsFields(context),
        ],
      ),
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget _buildDetailsFields(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ReadOnlyField(
                  label: 'First Name',
                  value: member.firstName,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ReadOnlyField(
                  label: 'Last Name',
                  value: member.lastName,
                ),
              ),
            ],
          ),
        ),

        ReadOnlyField(label: 'Email', value: member.email),
        const SizedBox(height: 16),

        ReadOnlyField(label: 'Status', value: toTitleCase(member.status.value)),
        const SizedBox(height: 16),

        ReadOnlyField(label: 'Added At', value: formatDate(member.addedAt)),
      ],
    );
  }
}
