import 'package:flutter/material.dart';
import 'package:flutter_application_1/ui/web_operator/view_model/team_members_notifier.dart';
import 'package:flutter_application_1/ui/web_operator/widgets/edit_operator_dialog.dart';

class ActionButtons extends StatelessWidget {
  final TeamMembersNotifier notifier;
  final dynamic member;

  const ActionButtons({
    super.key,
    required this.notifier,
    required this.member,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(Icons.edit_outlined),
          onPressed: () => _showEditDialog(context, notifier, member),
          tooltip: 'Edit Member',
        ),
        IconButton(
          icon: Icon(Icons.visibility_outlined),
          onPressed: null,
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
}
