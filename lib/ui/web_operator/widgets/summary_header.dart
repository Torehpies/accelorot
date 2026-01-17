import 'package:flutter/material.dart';
import 'package:flutter_application_1/data/providers/auth_providers.dart';
import 'package:flutter_application_1/data/providers/team_providers.dart';
import 'package:flutter_application_1/data/services/api/model/team/team.dart';
import 'package:flutter_application_1/ui/core/themes/app_theme.dart';
import 'package:flutter_application_1/ui/core/themes/web_colors.dart';
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
              _SummaryCard(
                title: 'Active Operators',
                value: '—',
                icon: Icons.person,
                iconBackgroundColor: AppColors.greenBackground,
                iconForegroundColor: AppColors.greenForeground,
              ),
              _SummaryCard(
                title: 'Archived Operators',
                value: '—',
                icon: Icons.person,
                iconBackgroundColor: AppColors.yellowBackground,
                iconForegroundColor: AppColors.yellowForeground,
              ),
              _SummaryCard(
                title: 'Former Operators',
                value: '—',
                icon: Icons.person,
                iconBackgroundColor: AppColors.redBackground,
                iconForegroundColor: AppColors.redForeground,
              ),
              _SummaryCard(
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
    final activeOperators = team.activeOperators;
    final archivedOperators = team.archivedOperators;

    return Row(
      children: [
        _SummaryCard(
          title: 'Active Operators',
          value: '$activeOperators',
          icon: Icons.person,
          iconBackgroundColor: AppColors.greenBackground,
          iconForegroundColor: AppColors.greenForeground,
        ),
        const SizedBox(width: 12),
        _SummaryCard(
          title: 'Archived Operators',
          value: '$archivedOperators',
          icon: Icons.person,
          iconBackgroundColor: AppColors.yellowBackground,
          iconForegroundColor: AppColors.yellowForeground,
        ),
        const SizedBox(width: 12),
        _SummaryCard(
          title: 'Former Operators',
          value: '${team.formerOperators}',
          icon: Icons.person,
          iconBackgroundColor: AppColors.redBackground,
          iconForegroundColor: AppColors.redForeground,
        ),
        const SizedBox(width: 12),
        _SummaryCard(
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

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color iconBackgroundColor;
  final Color iconForegroundColor;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.iconBackgroundColor,
    required this.iconForegroundColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.background2,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: WebColors.cardBorder, width: 1),
          boxShadow: [
            BoxShadow(
              color: WebColors.cardShadow,
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: WebColors.textLabel,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: iconBackgroundColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 20, color: iconForegroundColor),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.w700,
                color: WebColors.textHeading,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 5),
            // const Divider(height: 1, color: WebColors.dividerLight),
            // const SizedBox(height: 5),
          ],
        ),
      ),
    );
  }
}
