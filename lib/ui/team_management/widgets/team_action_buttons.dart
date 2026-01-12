import 'package:flutter/material.dart';
import 'package:flutter_application_1/ui/core/ui/confirm_dialog.dart';
import 'package:flutter_application_1/ui/team_management/view_model/team_management_notifier.dart';

class TeamActionButtons extends StatelessWidget {
  final TeamManagementNotifier notifier;
  final dynamic team;

  const TeamActionButtons({
    super.key,
    required this.notifier,
    required this.team,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(Icons.check),
          // onPressed: () => _showAcceptDialog(context),
          onPressed: null,
          tooltip: 'Accept Member',
        ),
        IconButton(
          icon: Icon(Icons.cancel_outlined),
          // onPressed: () => _showDeclineDialog(context),
          onPressed: null,
          tooltip: 'Decline Member',
        ),
      ],
    );
  }

  // Future<void> _showAcceptDialog(BuildContext context) async {
  //   final confirmed = await showConfirmDialog(
  //     context: context,
  //     title: 'Accept Request',
  //     message: 'Accept ${team.firstName} ${team.lastName}?',
  //   );
  //   if (confirmed == true) {
  //     await notifier.acceptRequest(team);
  //   }
  // }
  //
  // Future<void> _showDeclineDialog(BuildContext context) async {
  //   final confirmed = await showConfirmDialog(
  //     context: context,
  //     title: 'Decline Request',
  //     message: 'Decline ${team.firstName} ${team.lastName}?',
  //   );
  //   if (confirmed == true) {
  //     await notifier.declineRequest(team);
  //   }
  // }
}
