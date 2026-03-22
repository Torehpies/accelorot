import 'package:flutter/material.dart';
import 'package:flutter_application_1/data/providers/auth_providers.dart';
import 'package:flutter_application_1/data/providers/team_providers.dart';
import 'package:flutter_application_1/ui/core/widgets/sample_cards/base_stats_card.dart';
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

        final countsAsync = ref.watch(teamMemberCountsProvider);

        return countsAsync.when(
          data: (counts) => _buildStatsRow(counts),
          loading: () => _buildShimmerRow(),
          error: (error, stack) => Text('Error: $error'),
        );
      },
      loading: () => _buildShimmerRow(),
      error: (error, stack) => Text('User Error: $error'),
    );
  }
}

/// Builds stat cards from a live status → count map
Row _buildStatsRow(Map<String, int> counts) {
  final active = counts['active'] ?? 0;
  final archived = counts['archived'] ?? 0;
  final former = counts['removed'] ?? 0;
  // Both 'pending' and 'approval' statuses are awaiting acceptance
  final pending = (counts['pending'] ?? 0) + (counts['approval'] ?? 0);

  return Row(
    children: [
      // Active Operators — green
      Expanded(
        child: BaseStatsCard(
          title: 'Active Operators',
          value: active,
          icon: Icons.person,
          iconColor: const Color(0xFF09632C),
          backgroundColor: const Color(0xFFCCFFD9),
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
          value: archived,
          icon: Icons.person,
          iconColor: const Color(0xFFA05E00),
          backgroundColor: const Color(0xFFFFFEB7),
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
          value: former,
          icon: Icons.person,
          iconColor: const Color(0xFF8D1012),
          backgroundColor: const Color(0xFFFFCCCD),
          changeText: '+0%',
          subtext: 'operators retired this month',
          isPositive: true,
        ),
      ),
      const SizedBox(width: 16),

      // Pending Requests — blue
      Expanded(
        child: BaseStatsCard(
          title: 'Pending Requests',
          value: pending,
          icon: Icons.person,
          iconColor: const Color(0xFF374151),
          backgroundColor: const Color(0xFFC9E1FC),
          changeText: '+0%',
          subtext: 'new operators this month',
          isPositive: true,
        ),
      ),
    ],
  );
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
          title: 'Pending Requests',
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
          title: 'Pending Requests',
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
