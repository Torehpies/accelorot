import 'package:flutter/material.dart';
import 'package:flutter_application_1/ui/core/widgets/dialog_shell.dart';
import 'package:flutter_application_1/ui/core/widgets/read_only_field.dart';
import 'package:flutter_application_1/utils/format.dart';
import 'package:flutter_application_1/data/services/api/model/team_member/team_member.dart';

class ViewOperatorDialog extends StatelessWidget {
  final TeamMember operator;

  const ViewOperatorDialog({super.key, required this.operator});

  @override
  Widget build(BuildContext context) {
    return DialogShell(
      title: const Text(
        'Operator Details',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('View in-depth information about this operator.'),
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
                  value: operator.firstName,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ReadOnlyField(
                  label: 'Last Name',
                  value: operator.lastName,
                ),
              ),
            ],
          ),
        ),

        ReadOnlyField(label: 'Email', value: operator.email),
        const SizedBox(height: 16),

        ReadOnlyField(
          label: 'Status',
          value: toTitleCase(operator.status.value),
        ),
        const SizedBox(height: 16),

        ReadOnlyField(
          label: 'Added At',
          value: formatDateAndTime(operator.addedAt),
        ),
      ],
    );
  }
}
