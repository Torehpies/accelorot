import 'package:flutter/material.dart';
import 'package:flutter_application_1/ui/core/ui/status_message.dart';
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
    final state = ref.watch(teamManagementProvider);

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
                  onPressed: state.teams.isLoading || state.isSavingTeams
                      ? null
                      : () => _showAddTeamDialog(context),
                  label: Text("Add Team"),
                  icon: Icon(Icons.add),
                ),
              ],
            ),
          ),
        Expanded(
          child: state.teams.when(
            data: (teams) => teams.isEmpty
                ? StatusMessage(
                    title: "No teams yet",
                    icon: Icons.group,
                    description: "Tap the + button to create teams",
                  )
                : ListView.builder(
                    itemCount: teams.length,
                    itemBuilder: (context, index) {
                      final team = teams[index];

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primary,
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
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => StatusMessage(
              title: "Error loading teams",
              icon: Icons.error,
              description: error.toString(),
            ),
          ),
        ),
      ],
    );
  }
}
