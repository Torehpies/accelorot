import 'package:flutter/material.dart';
import 'package:flutter_application_1/data/providers/auth_providers.dart';
import 'package:flutter_application_1/data/providers/team_providers.dart';
import 'package:flutter_application_1/data/services/api/model/team/team.dart';
import 'package:flutter_application_1/ui/core/themes/app_theme.dart';
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
              _SummaryCard(title: 'Active Operators', value: '—'),
              _SummaryCard(title: 'Archived Operators', value: '—'),
              _SummaryCard(title: 'Former Operators', value: '—'),
              _SummaryCard(title: 'New Operators', value: '—'),
            ],
          );
        }

        final teamAsync = ref.watch(currentTeamProvider);

        return teamAsync.when(
          data: (team) => _TeamSummaryRow(team: team), // Use team data
          loading: () => const CircularProgressIndicator(),
          error: (error, stack) => Text('Team Error: $error'),
        );
      },
      loading: () => const CircularProgressIndicator(),
      error: (error, stack) => Text('User Error: $error'),
    );
  }
}

class _TeamSummaryRow extends ConsumerWidget {
  final Team team;
  const _TeamSummaryRow({required this.team});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Fetch operator stats from team or service
    final activeOperators = team.activeOperators;
    final archivedOperators = team.archivedOperators;
    // Add providers for dynamic counts if needed

    return Row(
      children: [
        _SummaryCard(title: 'Active Operators', value: '$activeOperators'),
        const SizedBox(width: 12),
        _SummaryCard(title: 'Archived Operators', value: '$archivedOperators'),
        const SizedBox(width: 12),
        _SummaryCard(
          title: 'Former Operators',
          value: '${team.formerOperators}',
        ),
        const SizedBox(width: 12),
        _SummaryCard(title: 'New Operators', value: '${team.newOperators}'),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;

  const _SummaryCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.background2,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.labelMedium?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
