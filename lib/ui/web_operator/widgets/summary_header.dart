import 'package:flutter/material.dart';
import 'package:flutter_application_1/data/providers/auth_providers.dart';
import 'package:flutter_application_1/data/providers/team_providers.dart';
import 'package:flutter_application_1/data/services/api/model/team/team.dart';
import 'package:flutter_application_1/ui/core/themes/app_theme.dart';
import 'package:flutter_application_1/ui/web_operator/widgets/summary_card.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SummaryHeader extends ConsumerWidget {
  const SummaryHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final teamUserAsync = ref.watch(appUserProvider);

    return teamUserAsync.when(
      data: (teamUser) {
        if (teamUser?.teamId == null) {
          return const Row(
            children: [
              SummaryCard(
                title: 'Active Operators',
                value: '—',
                icon: Icons.person,
                iconBackgroundColor: AppColors.greenBackground,
                iconForegroundColor: AppColors.greenForeground,
              ),
              SummaryCard(
                title: 'Archived Operators',
                value: '—',
                icon: Icons.person,
                iconBackgroundColor: AppColors.yellowBackground,
                iconForegroundColor: AppColors.yellowForeground,
              ),
              SummaryCard(
                title: 'Former Operators',
                value: '—',
                icon: Icons.person,
                iconBackgroundColor: AppColors.redBackground,
                iconForegroundColor: AppColors.redForeground,
              ),
              SummaryCard(
                title: 'New Operators',
                value: '—',
                icon: Icons.person,
                iconBackgroundColor: AppColors.blueBackground,
                iconForegroundColor: AppColors.blueForeground,
              ),
            ],
          );
        }

        final teamAsync = ref.watch(currentTeamProvider);

        return teamAsync.when(
          data: (team) => _TeamSummaryRow(team: team),
          loading: () => _buildShimmerRow(),
          error: (error, stack) => Text('Team Error: $error'),
        );
      },
      loading: () => const CircularProgressIndicator(),
      error: (error, stack) => Text('User Error: $error'),
    );
  }
}

Row _buildShimmerRow() {
  return const Row(
    children: [
      SummaryCard(
        isLoading: true,
        title: '',
        value: '',
        icon: Icons.person,
        iconBackgroundColor: Colors.grey,
        iconForegroundColor: Colors.grey,
      ),
      SizedBox(width: 12),
      SummaryCard(
        isLoading: true,
        title: '',
        value: '',
        icon: Icons.person,
        iconBackgroundColor: Colors.grey,
        iconForegroundColor: Colors.grey,
      ),
      SizedBox(width: 12),
      SummaryCard(
        isLoading: true,
        title: '',
        value: '',
        icon: Icons.person,
        iconBackgroundColor: Colors.grey,
        iconForegroundColor: Colors.grey,
      ),
      SizedBox(width: 12),
      SummaryCard(
        isLoading: true,
        title: '',
        value: '',
        icon: Icons.person,
        iconBackgroundColor: Colors.grey,
        iconForegroundColor: Colors.grey,
      ),
    ],
  );
}

class _TeamSummaryRow extends ConsumerWidget {
  final Team team;
  const _TeamSummaryRow({required this.team});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeOperators = team.activeOperators;
    final archivedOperators = team.archivedOperators;

    return Row(
      children: [
        SummaryCard(
          title: 'Active Operators',
          value: '$activeOperators',
          icon: Icons.person,
          iconBackgroundColor: AppColors.greenBackground,
          iconForegroundColor: AppColors.greenForeground,
        ),
        const SizedBox(width: 12),
        SummaryCard(
          title: 'Archived Operators',
          value: '$archivedOperators',
          icon: Icons.person,
          iconBackgroundColor: AppColors.yellowBackground,
          iconForegroundColor: AppColors.yellowForeground,
        ),
        const SizedBox(width: 12),
        SummaryCard(
          title: 'Former Operators',
          value: '${team.formerOperators}',
          icon: Icons.person,
          iconBackgroundColor: AppColors.redBackground,
          iconForegroundColor: AppColors.redForeground,
        ),
        const SizedBox(width: 12),
        SummaryCard(
          title: 'New Operators',
          value: '${team.newOperators}',
          icon: Icons.person,
          iconBackgroundColor: AppColors.blueBackground,
          iconForegroundColor: AppColors.blueForeground,
        ),
      ],
    );
  }
}
