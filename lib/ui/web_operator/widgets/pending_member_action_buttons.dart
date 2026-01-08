import 'package:flutter/material.dart';
import 'package:flutter_application_1/ui/web_operator/view_model/pending_members_notifier.dart';
import 'package:flutter_application_1/ui/web_operator/view_model/team_members_notifier.dart';
import 'package:flutter_application_1/ui/web_operator/widgets/edit_operator_dialog.dart';
import 'package:flutter_application_1/ui/web_operator/widgets/view_operator_dialog.dart';

class PendingMemberActionButtons extends StatelessWidget {
  final PendingMembersNotifier notifier;
  final dynamic member;

  const PendingMemberActionButtons({
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
          icon: Icon(Icons.check),
          // onPressed: () => _showEditDialog(context, notifier, member),
					onPressed: null,
          tooltip: 'Accept Member',
        ),
        IconButton(
          icon: Icon(Icons.cancel_outlined),
          // onPressed: () => _showViewDialog(context, notifier, member),
					onPressed: null,
          tooltip: 'Decline Member',
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
