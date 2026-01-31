// lib/ui/mobile_admin_home/widgets/swipeable_stat_cards.dart

import 'package:flutter/material.dart';
import '../../core/widgets/base_stats_card.dart';
import 'dart:ui';

class StatCardData {
  final String title;
  final int value;
  final double growth;
  final IconData icon;
  final Color iconBackgroundColor;

  const StatCardData({
    required this.title,
    required this.value,
    required this.growth,
    required this.icon,
    required this.iconBackgroundColor,
  });
}

class _AppScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
  };
}

class SwipeableStatCards extends StatelessWidget {
  final List<StatCardData> cards;

  const SwipeableStatCards({super.key, required this.cards});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160,
      child: PageView.builder(
        scrollBehavior: _AppScrollBehavior(),
        padEnds: false,
        itemCount: cards.length,
        controller: PageController(viewportFraction: 0.9),
        itemBuilder: (context, index) {
          final card = cards[index];
          final isPositive = card.growth >= 0;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: BaseStatsCard(
              title: card.title,
              value: card.value,
              icon: card.icon,
              iconColor: card.iconBackgroundColor,
              backgroundColor: card.iconBackgroundColor.withValues(alpha: 0.1),
              changeText: '${card.growth.abs().toStringAsFixed(0)}%',
              subtext: 'compared this month',
              isPositive: isPositive,
            ),
          );
        },
      ),
    );
  }
}
