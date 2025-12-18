import 'package:flutter/material.dart';
import 'package:flutter_application_1/ui/team_management/view_model/team_management_notifier.dart';
import 'package:flutter_application_1/ui/team_management/widgets/add_team_dialog.dart';
import 'package:flutter_application_1/ui/team_management/widgets/desktop_team_management_view.dart';
import 'package:flutter_application_1/ui/team_management/widgets/mobile_team_management_view.dart';
import 'package:flutter_application_1/ui/core/ui/responsive_layout.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TeamManagementScreen extends ConsumerWidget {
  const TeamManagementScreen({super.key});

  void _showAddTeamDialog(BuildContext context) {
    showDialog(context: context, builder: (_) => AddTeamDialog());
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
		//TODO FIX ACCEPT OPERATOR
    final teams = ref.watch(
      teamManagementProvider.select((s) => s.teams),
    );

    final isSaving = ref.watch(
      teamManagementProvider.select((s) => s.isSavingTeams),
    );

    final isMobile = MediaQuery.of(context).size.width < 800;

    return Scaffold(
      appBar: AppBar(
        title: Text("Team Management", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.yellow.shade800,
        actions: [
          IconButton(
            onPressed: (teams.isLoading || isSaving)
                ? null
                : () {
                    ref
                        .read(teamManagementProvider.notifier)
                        .getTeams(forceRefresh: true);
                  },
            icon: teams.isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(color: Colors.white),
                  )
                : Icon(Icons.refresh, color: Colors.white),
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: teams.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: ResponsiveLayout(
                mobileView: MobileTeamManagementView(),
                desktopView: DesktopTeamManagementView(),
              ),
            ),
      floatingActionButton: isMobile
          ? FloatingActionButton(
              onPressed: () => _showAddTeamDialog(context),
              backgroundColor: Colors.yellow.shade800,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }
}
