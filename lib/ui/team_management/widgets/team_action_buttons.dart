import 'package:flutter/material.dart';
import 'package:flutter_application_1/ui/team_management/view_model/team_management_notifier.dart';
import 'package:flutter_application_1/ui/team_management/widgets/view_team_dialog.dart';

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
          icon: Icon(Icons.info),
          onPressed: () => _showViewDialog(context, team),
          tooltip: 'View Team',
        ),
      ],
    );
  }

  void _showViewDialog(BuildContext context, dynamic team) {
    showDialog(
      context: context,
      builder: (_) => ViewTeamDialog(team: team),
    );
  }
}
