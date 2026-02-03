import 'package:flutter/material.dart';
import 'package:flutter_application_1/ui/web_operator/view_model/team_members_notifier.dart';
import 'package:flutter_application_1/ui/web_operator/widgets/action_icon_button.dart';
import 'package:flutter_application_1/ui/web_operator/widgets/edit_operator_dialog.dart';
import 'package:flutter_application_1/ui/web_operator/widgets/view_operator_dialog.dart';

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
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        actionIconButton(
          icon: Icons.edit_outlined,
          onPressed: () => _showEditDialog(context, notifier, member),
          tooltip: 'Edit Member',
        ),
        actionIconButton(
          icon: Icons.visibility_outlined,
          onPressed: () => _showViewDialog(context, notifier, member),
          tooltip: 'View Member',
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
