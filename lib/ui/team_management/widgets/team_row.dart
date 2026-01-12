import 'package:flutter/material.dart';
import 'package:flutter_application_1/ui/team_management/view_model/team_management_notifier.dart';
import 'package:flutter_application_1/ui/team_management/widgets/team_action_buttons.dart';
import 'package:flutter_application_1/utils/format.dart';

class TeamRow extends StatelessWidget {
  final dynamic team;
  final TeamManagementNotifier notifier;

  const TeamRow({super.key, this.team, required this.notifier});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey[200]!, width: 1)),
      ),
      child: Row(
        children: [
          Expanded(flex: 2, child: Center(child: Text(team.teamName))),
          Expanded(flex: 2, child: Center(child: Text(team.address))),
          Expanded(
            flex: 1,
            child: Center(
              child: TeamActionButtons(notifier: notifier, team: team),
            ),
          ),
        ],
      ),
    );
  }
}
