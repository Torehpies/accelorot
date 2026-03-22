// lib/ui/web_operator/widgets/pending_member_action_buttons.dart

import 'package:flutter/material.dart';
import 'package:flutter_application_1/ui/core/widgets/dialog/web_confirmation_dialog.dart';
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
          onPressed: () => _handleAccept(context),
        ),
        TableActionButton(
          icon: Icons.cancel_outlined,
          tooltip: 'Decline Member',
          onPressed: () => _handleDecline(context),
        ),
      ],
    );
  }

  Future<void> _handleAccept(BuildContext context) async {
    final result = await WebConfirmationDialog.show(
      context,
      title: 'Accept Request',
      message: 'Are you sure you want to accept ${member.firstName} ${member.lastName}?',
      confirmLabel: 'Accept',
      cancelLabel: 'Cancel',
      confirmIsDestructive: false,
    );

    if (result == ConfirmResult.confirmed) {
      await notifier.acceptRequest(member);
    }
  }

  Future<void> _handleDecline(BuildContext context) async {
    final result = await WebConfirmationDialog.show(
      context,
      title: 'Decline Request',
      message: 'Are you sure you want to decline ${member.firstName} ${member.lastName}? This action cannot be undone.',
      confirmLabel: 'Decline',
      cancelLabel: 'Cancel',
      confirmIsDestructive: true,
    );

    if (result == ConfirmResult.confirmed) {
      await notifier.declineRequest(member);
    }
  }
}