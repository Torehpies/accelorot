import 'package:flutter/material.dart';
import 'package:flutter_application_1/ui/core/themes/app_theme.dart';
import 'package:flutter_application_1/ui/team_management/view_model/team_management_notifier.dart';
import 'package:flutter_application_1/ui/team_management/widgets/team_management_header.dart';
import 'package:flutter_application_1/ui/team_management/widgets/team_management_state.dart';
import 'package:flutter_application_1/ui/team_management/widgets/team_row.dart';
import 'package:flutter_application_1/ui/web_operator/widgets/pagination_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DesktopTeamManagementView extends ConsumerWidget {
  const DesktopTeamManagementView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(teamManagementProvider);
    final notifier = ref.read(teamManagementProvider.notifier);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: AppColors.background2,
        ),
        child: Column(
          children: [
            TeamManagementHeader(),
            Expanded(
              child: _TableContent(state: state, notifier: notifier),
            ),
            const SizedBox(height: 12),
            _PaginationSection(
              currentPage: state.currentPage,
              hasNextPage: state.hasNextPage,
              notifier: notifier,
            ),
            const SizedBox(height: 12),
            //   if (MediaQuery.of(context).size.width >= 800)
            //     Padding(
            //       padding: const EdgeInsets.only(bottom: 16),
            //       child: Row(
            //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //         children: [
            //           Text(
            //             'Team List',
            //             style: Theme.of(context).textTheme.titleLarge,
            //           ),
            //           Row(
            //             children: [
            //               ElevatedButton.icon(
            //                 onPressed:
            //                     state.teams.isLoading || state.isSavingTeams
            //                     ? null
            //                     : () => _showAddTeamDialog(context),
            //                 label: Text("Add Team"),
            //                 icon: Icon(Icons.add),
            //               ),
            //               IconButton(
            //                 onPressed: (teams.isLoading || isSaving)
            //                     ? null
            //                     : () {
            //                         ref
            //                             .read(teamManagementProvider.notifier)
            //                             .getTeams(forceRefresh: true);
            //                       },
            //                 icon: teams.isLoading
            //                     ? const SizedBox(
            //                         width: 24,
            //                         height: 24,
            //                         child: CircularProgressIndicator(
            //                           color: Colors.white,
            //                         ),
            //                       )
            //                     : Icon(Icons.refresh, color: Colors.white),
            //               ),
            //             ],
            //           ),
            //         ],
            //       ),
            //     ),
            //   Expanded(
            //     child: state.teams.when(
            //       data: (teams) => teams.isEmpty
            //           ? StatusMessage(
            //               title: "No teams yet",
            //               icon: Icons.group,
            //               description: "Tap the + button to create teams",
            //             )
            //           : ListView.builder(
            //               itemCount: teams.length,
            //               itemBuilder: (context, index) {
            //                 final team = teams[index];
            //
            //                 return ListTile(
            //                   leading: CircleAvatar(
            //                     backgroundColor: Theme.of(
            //                       context,
            //                     ).colorScheme.primary,
            //                     child: Text(team.teamName[0].toUpperCase()),
            //                   ),
            //                   title: Text(
            //                     team.teamName,
            //                     style: TextStyle(fontWeight: FontWeight.bold),
            //                   ),
            //                   subtitle: Text(team.address),
            //                 );
            //               },
            //             ),
            //       loading: () => const Center(child: CircularProgressIndicator()),
            //       error: (error, stack) => StatusMessage(
            //         title: "Error loading teams",
            //         icon: Icons.error,
            //         description: error.toString(),
            //       ),
            //     ),
            //   ),
          ],
        ),
      ),
    );
  }
}

class _TableContent extends StatelessWidget {
  final TeamManagementState state;
  final TeamManagementNotifier notifier;

  const _TableContent({required this.state, required this.notifier});

  @override
  Widget build(BuildContext context) {
    if (state.isLoading && state.teams.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(width: 1, color: AppColors.grey),
        borderRadius: BorderRadius.circular(20),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          children: [
            _StickyHeader(),
            Expanded(
              child: _MembersList(state: state, notifier: notifier),
            ),
          ],
        ),
      ),
    );
  }
}

class _StickyHeader extends StatelessWidget {
  const _StickyHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(color: Color(0xFFEFF7FF)),
      child: const Row(
        children: [
          Expanded(
            flex: 2,
            child: Center(
              child: Text(
                'Team Name',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Center(
              child: Text(
                'Address',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: Text(
                'Actions',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MembersList extends StatelessWidget {
  final TeamManagementState state;
  final TeamManagementNotifier notifier;

  const _MembersList({required this.state, required this.notifier});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: state.teams.length,
      itemBuilder: (context, index) =>
          TeamRow(team: state.teams[index], notifier: notifier),
    );
  }
}

class _PaginationSection extends ConsumerWidget {
  final int currentPage;
  final bool hasNextPage;
  final TeamManagementNotifier notifier;

  const _PaginationSection({
    required this.currentPage,
    required this.hasNextPage,
    required this.notifier,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PaginationBar(
      currentPage: currentPage,
      canGoNext: hasNextPage,
      onBack: notifier.previousPage,
      onNext: notifier.nextPage,
      onPageSelected: notifier.goToPage,
    );
  }
}