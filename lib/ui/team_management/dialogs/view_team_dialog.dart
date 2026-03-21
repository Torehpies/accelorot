// lib/ui/team_management/dialogs/view_team_dialog.dart

import 'package:flutter/material.dart';
import 'package:flutter_application_1/data/services/api/model/team/team.dart';
import 'package:flutter_application_1/ui/core/widgets/dialog/base_dialog.dart';
import 'package:flutter_application_1/ui/core/widgets/dialog/dialog_action.dart';
import 'package:flutter_application_1/ui/core/widgets/dialog/dialog_fields.dart';
import 'package:flutter_application_1/utils/format.dart';

class ViewTeamDialog extends StatelessWidget {
  final Team team;

  const ViewTeamDialog({super.key, required this.team});

  @override
  Widget build(BuildContext context) {
    return BaseDialog(
      title: team.teamName,
      subtitle: 'Team Details',
      content: ReadOnlySection(
        fields: [
          // ── Identity
          ReadOnlyField(
            label: 'Team ID',
            value: team.teamId ?? '—',
          ),
          ReadOnlyField(
            label: 'Team Name',
            value: team.teamName,
          ),

          // ── Address
          ReadOnlyField(
            label: 'Address',
            value: team.address,
          ),          
          ReadOnlyField(
            label: 'City',
            value: team.city ?? '—',
          ),
          ReadOnlyField(
            label: 'Region',
            value: team.region ?? '—',
          ),
          
          // ── Audit
          ReadOnlyField(
            label: 'Created At',
            value: team.createdAt != null
                ? formatDateAndTime(team.createdAt!)
                : '—',
          ),
          ReadOnlyField(
            label: 'Updated At',
            value: team.updatedAt != null
                ? formatDateAndTime(team.updatedAt!)
                : '—',
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