import 'package:flutter/material.dart';
import 'package:flutter_application_1/ui/core/ui/confirm_dialog.dart';
import 'package:flutter_application_1/ui/web_operator/view_model/pending_members_notifier.dart';
import 'package:flutter_application_1/ui/web_operator/widgets/action_icon_button.dart';

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
        actionIconButton(
          icon: Icons.check,
          onPressed: () => _showAcceptDialog(context),
          tooltip: 'Accept Member',
        ),
        actionIconButton(
          icon: Icons.cancel_outlined,
          onPressed: () => _showDeclineDialog(context),
          tooltip: 'Decline Member',
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
