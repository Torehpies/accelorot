import 'package:flutter/material.dart';
import 'package:flutter_application_1/data/providers/auth_providers.dart';
import 'package:flutter_application_1/data/providers/team_providers.dart';
import 'package:flutter_application_1/data/services/api/model/team/team.dart';
import 'package:flutter_application_1/ui/core/widgets/base_stats_card.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SummaryHeader extends ConsumerWidget {
  const SummaryHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final teamUserAsync = ref.watch(appUserProvider);

    return teamUserAsync.when(
      data: (teamUser) {
        if (teamUser?.teamId == null) {
          return _buildPlaceholderRow();
        }

        final teamAsync = ref.watch(currentTeamProvider);

        return teamAsync.when(
          data: (team) => _TeamSummaryRow(team: team),
          loading: () => _buildShimmerRow(),
          error: (error, stack) => Text('Team Error: $error'),
        );
      },
      loading: () => _buildShimmerRow(),
      error: (error, stack) => Text('User Error: $error'),
    );
  }
}

/// Placeholder row when no team is available yet — shows dashes
Row _buildPlaceholderRow() {
  return Row(
    children: [
      Expanded(
        child: BaseStatsCard(
          title: 'Active Operators',
          value: 0,
          icon: Icons.person,
          iconColor: const Color(0xFF09632C),
          backgroundColor: const Color(0xFFCCFFD9),
        ),
      ),
      const SizedBox(width: 16),
      Expanded(
        child: BaseStatsCard(
          title: 'Archived Operators',
          value: 0,
          icon: Icons.person,
          iconColor: const Color(0xFFA05E00),
          backgroundColor: const Color(0xFFFFFEB7),
        ),
      ),
      const SizedBox(width: 16),
      Expanded(
        child: BaseStatsCard(
          title: 'Former Operators',
          value: 0,
          icon: Icons.person,
          iconColor: const Color(0xFF8D1012),
          backgroundColor: const Color(0xFFFFCCCD),
        ),
      ),
      const SizedBox(width: 16),
      Expanded(
        child: BaseStatsCard(
          title: 'New Operators',
          value: 0,
          icon: Icons.person,
          iconColor: const Color(0xFF374151),
          backgroundColor: const Color(0xFFC9E1FC),
        ),
      ),
    ],
  );
}

/// Shimmer row shown while team data is loading
Row _buildShimmerRow() {
  return Row(
    children: [
      Expanded(
        child: BaseStatsCard(
          title: 'Active Operators',
          value: 0,
          icon: Icons.person,
          iconColor: const Color(0xFF09632C),
          backgroundColor: const Color(0xFFCCFFD9),
          isLoading: true,
        ),
      ),
      const SizedBox(width: 16),
      Expanded(
        child: BaseStatsCard(
          title: 'Archived Operators',
          value: 0,
          icon: Icons.person,
          iconColor: const Color(0xFFA05E00),
          backgroundColor: const Color(0xFFFFFEB7),
          isLoading: true,
        ),
      ),
      const SizedBox(width: 16),
      Expanded(
        child: BaseStatsCard(
          title: 'Former Operators',
          value: 0,
          icon: Icons.person,
          iconColor: const Color(0xFF8D1012),
          backgroundColor: const Color(0xFFFFCCCD),
          isLoading: true,
        ),
      ),
      const SizedBox(width: 16),
      Expanded(
        child: BaseStatsCard(
          title: 'New Operators',
          value: 0,
          icon: Icons.person,
          iconColor: const Color(0xFF374151),
          backgroundColor: const Color(0xFFC9E1FC),
          isLoading: true,
        ),
      ),
    ],
  );
}

class _TeamSummaryRow extends StatelessWidget {
  final Team team;
  const _TeamSummaryRow({required this.team});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Active Operators — green
        Expanded(
          child: BaseStatsCard(
            title: 'Active Operators',
            value: team.activeOperators,
            icon: Icons.person,
            iconColor: const Color(0xFF09632C),
            backgroundColor: const Color(0xFFCCFFD9),
            // TODO: Replace with real month-over-month data
            changeText: '+0%',
            subtext: 'activated operators this month',
            isPositive: true,
          ),
        ),
        const SizedBox(width: 16),

        // Archived Operators — amber
        Expanded(
          child: BaseStatsCard(
            title: 'Archived Operators',
            value: team.archivedOperators,
            icon: Icons.person,
            iconColor: const Color(0xFFA05E00),
            backgroundColor: const Color(0xFFFFFEB7),
            // TODO: Replace with real month-over-month data
            changeText: '+0%',
            subtext: 'archived operators this month',
            isPositive: true,
          ),
        ),
        const SizedBox(width: 16),

        // Former Operators — red
        Expanded(
          child: BaseStatsCard(
            title: 'Former Operators',
            value: team.formerOperators,
            icon: Icons.person,
            iconColor: const Color(0xFF8D1012),
            backgroundColor: const Color(0xFFFFCCCD),
            // TODO: Replace with real month-over-month data
            changeText: '+0%',
            subtext: 'operators retired this month',
            isPositive: true,
          ),
        ),
        const SizedBox(width: 16),

        // New Operators — blue
        Expanded(
          child: BaseStatsCard(
            title: 'New Operators',
            value: team.newOperators,
            icon: Icons.person,
            iconColor: const Color(0xFF374151),
            backgroundColor: const Color(0xFFC9E1FC),
            // TODO: Replace with real month-over-month data
            changeText: '+0%',
            subtext: 'new operators this month',
            isPositive: true,
          ),
        ),
      ],
    );
  }
}