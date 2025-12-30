// lib/ui/mobile_admin_home/widgets/swipeable_stat_cards.dart

import 'package:flutter/material.dart';
import 'stat_card.dart';

class SwipeableStatCards extends StatefulWidget {
  final List<StatCardData> cards;

  const SwipeableStatCards({super.key, required this.cards});

  @override
  State<SwipeableStatCards> createState() => _SwipeableStatCardsState();
}

class _SwipeableStatCardsState extends State<SwipeableStatCards> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 140,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: widget.cards.length,
            itemBuilder: (context, index) {
              final card = widget.cards[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
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
        ),
        const SizedBox(height: 12),
        // Page indicators
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.cards.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: _currentPage == index ? 24 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: _currentPage == index ? Colors.teal : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class StatCardData {
  final int count;
  final String label;
  final String? subtitle;
  final IconData? icon;
  final Color? iconColor;
  final Color? iconBackgroundColor;

  const StatCardData({
    required this.count,
    required this.label,
    this.subtitle,
    this.icon,
    this.iconColor,
    this.iconBackgroundColor,
  });
}
