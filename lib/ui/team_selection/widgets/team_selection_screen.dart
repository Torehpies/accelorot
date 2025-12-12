import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/data/services/api/model/team/team.dart';
import 'package:flutter_application_1/ui/core/themes/app_theme.dart';
import 'package:flutter_application_1/ui/core/ui/outline_app_button.dart';
import 'package:flutter_application_1/ui/team_selection/view_model/team_selection_notifier.dart';
import 'package:flutter_application_1/ui/team_selection/view_model/team_selection_state.dart';
import 'package:flutter_application_1/utils/ui_message.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TeamSelectionScreen extends ConsumerWidget {
  const TeamSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(teamSelectionProvider);
    final notifier = ref.read(teamSelectionProvider.notifier);
    final user = FirebaseAuth.instance.currentUser;
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 800;

    ref.listen<TeamSelectionState>(teamSelectionProvider, (prev, next) {
      final message = next.message;
      if (message != null && message != prev?.message) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final messenger = ScaffoldMessenger.maybeOf(context);
          final isCurrent = ModalRoute.of(context)?.isCurrent ?? false;
          if (messenger != null && isCurrent) {
            messenger.showSnackBar(
              SnackBar(
                content: Text(
                  message.when(success: (text) => text, error: (text) => text),
                ),
                backgroundColor: message.when(
                  success: (_) => Colors.green,
                  error: (_) => Colors.red,
                ),
              ),
            );
          }
        });
      }
    });

    return Scaffold(
      body: Center(
        child: Container(
          constraints: BoxConstraints(
            maxWidth: isDesktop ? 600 : double.infinity,
          ),
          child: Padding(
            padding: EdgeInsets.all(isDesktop ? 32 : 24),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: EdgeInsets.all(isDesktop ? 40 : 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.group_add,
                      size: isDesktop ? 60 : 50,
                      color: AppColors.green100,
                    ),
                    Text(
                      'Join a Team',
                      style: TextStyle(
                        fontSize: isDesktop ? 32 : 26,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: const Text(
                        "Hello there! Choose a team below to join.",
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Loading / Error / Empty
                    if (state.isLoadingTeams)
                      const Center(child: CircularProgressIndicator())
                    else if (state.teams.isEmpty)
                      Center(child: Text('No teams available'))
                    else
                      DropdownButtonFormField<Team>(
                        initialValue: state.selectedTeam,
                        decoration: InputDecoration(
                          labelText: 'Select a Team',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items: state.teams.map((team) {
                          return DropdownMenuItem<Team>(
                            value: team,
                            child: Text(team.teamName),
                          );
                        }).toList(),
                        onChanged: state.isSubmitting
                            ? null
                            : (team) => notifier.selectedTeam(team!),
                      ),

                    const SizedBox(height: 24),

                    ElevatedButton(
                      onPressed:
                          state.selectedTeam == null ||
                              state.isSubmitting ||
                              user == null
                          ? null
                          : () => notifier.submitTeamRequest(user),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      child: state.isSubmitting
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text(
                              'Submit Request',
                              style: TextStyle(fontSize: 16),
                            ),
                    ),
                    const SizedBox(height: 12),
                    OutlineAppButton(
                      text: 'Logout',
                      onPressed: () => notifier.handleBackToLogin(),
                      isLoading: state.isSubmitting,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
