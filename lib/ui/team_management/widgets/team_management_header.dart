import 'package:flutter/material.dart';
import 'package:flutter_application_1/ui/team_management/widgets/add_team_dialog.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TeamManagementHeader extends ConsumerWidget {
  const TeamManagementHeader({super.key});

  void _showAddTeamDialog(BuildContext context) {
    showDialog(context: context, builder: (_) => AddTeamDialog());
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          SizedBox(width: 10),
          Icon(Icons.group),
          SizedBox(width: 10),
          Text(
            "Teams",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: () {
							_showAddTeamDialog(context);
						},
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            child: const Row(
              children: [Icon(Icons.add), SizedBox(width: 5), Text('Add Team')],
            ),
          ),
        ],
      ),
    );
  }
}
