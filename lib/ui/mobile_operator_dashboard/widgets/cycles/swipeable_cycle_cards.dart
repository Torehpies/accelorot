import 'package:flutter/material.dart';
import 'drum_control_card.dart';
import 'aerator_card.dart';
import '../../../../data/models/batch_model.dart';

class SwipeableCycleCards extends StatefulWidget {
  final BatchModel? currentBatch;

  const SwipeableCycleCards({
    super.key,
    required this.currentBatch,
  });

  @override
  State<SwipeableCycleCards> createState() => _SwipeableCycleCardsState();
}

class _SwipeableCycleCardsState extends State<SwipeableCycleCards> {
  final PageController _pageController = PageController(
    viewportFraction: 0.92, // Shows partial view of next card
  );
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
          height: 340, // Adjusted height for cycle cards
          child: PageView(
            controller: _pageController,
            padEnds: false,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: DrumControlCard(currentBatch: widget.currentBatch),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: AeratorCard(currentBatch: widget.currentBatch),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Page indicators
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: _currentPage == 0 ? 24 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: _currentPage == 0 ? Colors.teal : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: _currentPage == 1 ? 24 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: _currentPage == 1 ? Colors.teal : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ],
    );
  }
}