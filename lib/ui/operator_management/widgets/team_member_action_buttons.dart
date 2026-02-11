// lib/ui/web_operator/widgets/team_member_action_buttons.dart

import 'package:flutter/material.dart';
import 'package:flutter_application_1/ui/core/widgets/table/table_action_buttons.dart';
import 'package:flutter_application_1/ui/operator_management/view_model/team_members_notifier.dart';
import 'package:flutter_application_1/ui/operator_management/widgets/edit_operator_dialog.dart';
import 'package:flutter_application_1/ui/operator_management/widgets/view_operator_dialog.dart';

class TeamMemberActionButtons extends StatelessWidget {
  final TeamMembersNotifier notifier;
  final dynamic member;

  const TeamMemberActionButtons({
    super.key,
    required this.notifier,
    required this.member,
  });

  @override
  Widget build(BuildContext context) {
    return TableActionButtons(
      actions: [
        // View first (swapped to match reports consistency)
        TableActionButton(
          icon: Icons.open_in_new,
          tooltip: 'View Member',
          onPressed: () => _showViewDialog(context, notifier, member),
        ),
        // Edit second
        TableActionButton(
          icon: Icons.edit_outlined,
          tooltip: 'Edit Member',
          onPressed: () => _showEditDialog(context, notifier, member),
        ),
      ],
    );
  }

  void _showEditDialog(
    BuildContext context,
    TeamMembersNotifier notifier,
    dynamic member,
  ) {
    showDialog(
      context: context,
      builder: (context) => EditOperatorDialog(
        operator: member,
        onSave: (updatedOperator) => notifier.updateOperator(updatedOperator),
      ),
    );
  }

  void _showViewDialog(
    BuildContext context,
    TeamMembersNotifier notifier,
    dynamic member,
  ) {
    showDialog(
      context: context,
      builder: (_) => ViewOperatorDialog(operator: member),
    );
  }
}