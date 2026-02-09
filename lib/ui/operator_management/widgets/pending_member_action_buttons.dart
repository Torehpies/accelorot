// lib/ui/web_operator/widgets/pending_member_action_buttons.dart

import 'package:flutter/material.dart';
import 'package:flutter_application_1/ui/core/ui/confirm_dialog.dart';
import 'package:flutter_application_1/ui/core/widgets/table/table_action_buttons.dart';
import 'package:flutter_application_1/ui/operator_management/view_model/pending_members_notifier.dart';

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
    return TableActionButtons(
      actions: [
        TableActionButton(
          icon: Icons.check,
          tooltip: 'Accept Member',
          onPressed: () => _showAcceptDialog(context),
        ),
        TableActionButton(
          icon: Icons.cancel_outlined,
          tooltip: 'Decline Member',
          onPressed: () => _showDeclineDialog(context),
        ),
      ],
    );
  }

  Future<void> _showAcceptDialog(BuildContext context) async {
    final confirmed = await showConfirmDialog(
      context: context,
      title: 'Accept Request',
      message: 'Accept ${member.firstName} ${member.lastName}?',
    );
    if (confirmed == true) {
      await notifier.acceptRequest(member);
    }
  }

  Future<void> _showDeclineDialog(BuildContext context) async {
    final confirmed = await showConfirmDialog(
      context: context,
      title: 'Decline Request',
      message: 'Decline ${member.firstName} ${member.lastName}?',
    );
    if (confirmed == true) {
      await notifier.declineRequest(member);
    }
  }
}