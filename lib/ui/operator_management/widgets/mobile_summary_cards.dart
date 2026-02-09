import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/data/providers/auth_providers.dart';
import 'package:flutter_application_1/data/providers/team_providers.dart';
import 'package:flutter_application_1/data/services/api/model/team/team.dart';
import 'package:flutter_application_1/ui/core/themes/app_theme.dart';
import 'package:flutter_application_1/ui/operator_management/widgets/summary_card.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SummaryCardData {
  final String title;
  final String value;
  final IconData icon;
  final Color iconBackgroundColor;
  final Color iconForegroundColor;
  final bool isLoading;

  const SummaryCardData({
    required this.title,
    required this.value,
    required this.icon,
    required this.iconBackgroundColor,
    required this.iconForegroundColor,
    this.isLoading = false,
  });
}

class _AppScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
  };
}

class SwipeableSummaryCards extends StatelessWidget {
  final List<SummaryCardData> cards;

  const SwipeableSummaryCards({super.key, required this.cards});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: PageView.builder(
          scrollBehavior: _AppScrollBehavior(),
          padEnds: false,
          itemCount: cards.length,
          controller: PageController(viewportFraction: 0.9),
          itemBuilder: (context, index) {
            final card = cards[index];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: SummaryCard(
                title: card.title,
                value: card.value,
                icon: card.icon,
                iconBackgroundColor: card.iconBackgroundColor,
                iconForegroundColor: card.iconForegroundColor,
                isLoading: card.isLoading,
                isExpanded: false,
              ),
            );
          },
        ),
      ),
    );
  }
}

class MobileSummaryCards extends ConsumerWidget {
  const MobileSummaryCards({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final teamUserAsync = ref.watch(appUserProvider);

    return teamUserAsync.when(
      data: (teamUser) {
        if (teamUser?.teamId == null) {
          return SwipeableSummaryCards(cards: _placeholderCards());
        }

        final teamAsync = ref.watch(currentTeamProvider);
        return teamAsync.when(
          data: (team) => SwipeableSummaryCards(cards: _cardsFromTeam(team)),
          loading: () => SwipeableSummaryCards(cards: _loadingCards()),
          error: (error, _) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text('Team Error: $error'),
          ),
        );
      },
      loading: () => SwipeableSummaryCards(cards: _loadingCards()),
      error: (error, _) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Text('User Error: $error'),
      ),
    );
  }
}

List<SummaryCardData> _loadingCards() {
  return const [
    SummaryCardData(
      title: 'Active Operators',
      value: '',
      icon: Icons.person,
      iconBackgroundColor: Colors.grey,
      iconForegroundColor: Colors.grey,
      isLoading: true,
    ),
    SummaryCardData(
      title: 'Archived Operators',
      value: '',
      icon: Icons.person,
      iconBackgroundColor: Colors.grey,
      iconForegroundColor: Colors.grey,
      isLoading: true,
    ),
    SummaryCardData(
      title: 'Former Operators',
      value: '',
      icon: Icons.person,
      iconBackgroundColor: Colors.grey,
      iconForegroundColor: Colors.grey,
      isLoading: true,
    ),
    SummaryCardData(
      title: 'New Operators',
      value: '',
      icon: Icons.person,
      iconBackgroundColor: Colors.grey,
      iconForegroundColor: Colors.grey,
      isLoading: true,
    ),
  ];
}

List<SummaryCardData> _placeholderCards() {
  return const [
    SummaryCardData(
      title: 'Active Operators',
      value: '—',
      icon: Icons.person,
      iconBackgroundColor: AppColors.greenBackground,
      iconForegroundColor: AppColors.greenForeground,
    ),
    SummaryCardData(
      title: 'Archived Operators',
      value: '—',
      icon: Icons.person,
      iconBackgroundColor: AppColors.yellowBackground,
      iconForegroundColor: AppColors.yellowForeground,
    ),
    SummaryCardData(
      title: 'Former Operators',
      value: '—',
      icon: Icons.person,
      iconBackgroundColor: AppColors.redBackground,
      iconForegroundColor: AppColors.redForeground,
    ),
    SummaryCardData(
      title: 'New Operators',
      value: '—',
      icon: Icons.person,
      iconBackgroundColor: AppColors.blueBackground,
      iconForegroundColor: AppColors.blueForeground,
    ),
  ];
}

List<SummaryCardData> _cardsFromTeam(Team team) {
  return [
    SummaryCardData(
      title: 'Active Operators',
      value: '${team.activeOperators}',
      icon: Icons.person,
      iconBackgroundColor: AppColors.greenBackground,
      iconForegroundColor: AppColors.greenForeground,
    ),
    SummaryCardData(
      title: 'Archived Operators',
      value: '${team.archivedOperators}',
      icon: Icons.person,
      iconBackgroundColor: AppColors.yellowBackground,
      iconForegroundColor: AppColors.yellowForeground,
    ),
    SummaryCardData(
      title: 'Former Operators',
      value: '${team.formerOperators}',
      icon: Icons.person,
      iconBackgroundColor: AppColors.redBackground,
      iconForegroundColor: AppColors.redForeground,
    ),
    SummaryCardData(
      title: 'New Operators',
      value: '${team.newOperators}',
      icon: Icons.person,
      iconBackgroundColor: AppColors.blueBackground,
      iconForegroundColor: AppColors.blueForeground,
    ),
  ];
}
