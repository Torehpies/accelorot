import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'drum_control_card.dart';
import 'aerator_card.dart';
import '../../../../data/models/batch_model.dart';

class SwipeableCycleCards extends StatefulWidget {
  final BatchModel? currentBatch;
  final String? machineId;

  const SwipeableCycleCards({
    super.key,
    required this.currentBatch,
    this.machineId,
  });

  @override
  State<SwipeableCycleCards> createState() => _SwipeableCycleCardsState();
}

class _SwipeableCycleCardsState extends State<SwipeableCycleCards> {
  final ScrollController _scrollController = ScrollController();
  int _currentPage = 0;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth * 0.92;

    return Column(
      children: [
        NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            if (notification is ScrollUpdateNotification) {
              final page = (notification.metrics.pixels / cardWidth).round();
              if (page != _currentPage && page >= 0 && page <= 1) {
                setState(() {
                  _currentPage = page;
                });
              }
            }
            return false;
          },
          child: ScrollConfiguration(
            behavior: ScrollConfiguration.of(context).copyWith(
              dragDevices: {
                PointerDeviceKind.touch,
                PointerDeviceKind.mouse,
                PointerDeviceKind.trackpad,
              },
              scrollbars: false,
            ),
            child: SingleChildScrollView(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: cardWidth,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: DrumControlCard(
                        currentBatch: widget.currentBatch,
                        machineId: widget.machineId,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: cardWidth,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: AeratorCard(
                        currentBatch: widget.currentBatch,
                        machineId: widget.machineId,
                      ),
                    ),
                  ),
                ],
              ),
            ),
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