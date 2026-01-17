// lib/ui/mobile_admin_home/widgets/swipeable_stat_cards.dart

import 'package:flutter/material.dart';
import 'stat_card.dart';

class StatCardData {
  final int count;
  final String label;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final Color iconBackgroundColor;

  const StatCardData({
    required this.count,
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.iconBackgroundColor,
  });
}

class SwipeableStatCards extends StatelessWidget {
  final List<StatCardData> cards;

  const SwipeableStatCards({super.key, required this.cards});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: PageView.builder(
        itemCount: cards.length,
        controller: PageController(viewportFraction: 0.9),
        itemBuilder: (context, index) {
          final card = cards[index];
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: StatCard(
              count: card.count,
              label: card.label,
              subtitle: card.subtitle,
              icon: card.icon,
              iconColor: card.iconColor,
              iconBackgroundColor: card.iconBackgroundColor,
            ),
          );
        },
      ),
    );
  }
}