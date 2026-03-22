// lib/ui/team_management/dialogs/view_member_dialog.dart

import 'package:flutter/material.dart';
import 'package:flutter_application_1/data/services/api/model/team_member/team_member.dart';
import 'package:flutter_application_1/ui/core/widgets/dialog/base_dialog.dart';
import 'package:flutter_application_1/ui/core/widgets/dialog/dialog_action.dart';
import 'package:flutter_application_1/ui/core/widgets/dialog/dialog_fields.dart';
import 'package:flutter_application_1/utils/format.dart';
import 'package:flutter_application_1/utils/roles.dart';

class ViewMemberDialog extends StatelessWidget {
  final TeamMember member;

  const ViewMemberDialog({super.key, required this.member});

  @override
  Widget build(BuildContext context) {
    final label = member.teamRole == TeamRole.admin ? 'Admin' : 'Member';

    return BaseDialog(
      title: '${member.firstName} ${member.lastName}',
      subtitle: '$label Details',
      maxHeightFactor: 0.6,
      content: ReadOnlySection(
        fields: [
          ReadOnlyField(
            label: 'First Name',
            value: member.firstName,
          ),
          ReadOnlyField(
            label: 'Last Name',
            value: member.lastName,
          ),
          ReadOnlyField(
            label: 'Email',
            value: member.email,
          ),
          ReadOnlyField(
            label: 'Role',
            value: label,
          ),
          ReadOnlyField(
            label: 'Status',
            value: toTitleCase(member.status.value),
          ),
          ReadOnlyField(
            label: 'Added At',
            value: formatDate(member.addedAt),
          ),
        ],
      ),
      actions: [
        DialogAction.secondary(
          label: 'Close',
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}