import 'package:flutter/material.dart';
import 'package:flutter_application_1/ui/team_management/view_model/team_management_notifier.dart';
import 'package:flutter_application_1/ui/team_management/widgets/add_team_dialog.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TeamManagementLayout extends ConsumerWidget {
  const TeamManagementLayout({super.key});

  void _showAddTeamDialog(BuildContext context) {
    showDialog(context: context, builder: (_) => AddTeamDialog());
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final teams = ref.watch(teamManagementProvider.select((s) => s.teams));
    final isLoading = ref.watch(
      teamManagementProvider.select((s) => s.isLoadingTeams),
    );

    return Column(
      children: [
        if (MediaQuery.of(context).size.width >= 800)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Team List',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                ElevatedButton.icon(
                  onPressed: isLoading
                      ? null
                      : () => _showAddTeamDialog(context),
                  label: Text("Add Team"),
                  icon: Icon(Icons.add),
                ),
              ],
            ),
          ),
        Expanded(
          child: teams.isEmpty && !isLoading
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.people_outline, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        "No teams found.",
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                      Text(
                        "Tap the + button to create the first team.",
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: teams.length,
                  itemBuilder: (context, index) {
                    final team = teams[index];

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        child: Text(team.teamName[0].toUpperCase()),
                      ),
                      title: Text(
                        team.teamName,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(team.address),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
