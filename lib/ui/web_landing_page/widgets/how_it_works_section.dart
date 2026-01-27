// lib/ui/landing_page/widgets/how_it_works_section.dart

import 'package:flutter/material.dart';
import '../../core/themes/web_text_styles.dart';
import '../../core/themes/web_colors.dart';
import '../models/step_model.dart';
import 'step_card.dart';

class HowItWorksSection extends StatelessWidget {
  final List<StepModel> steps;

  const HowItWorksSection({
    super.key,
    required this.steps,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: width > 1400 ? 140 : 32,
        vertical: 100,
      ),
      color: const Color(0xFFEAF9FF),
      child: Column(
        children: [
          // Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFDFF5EE),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Simple Process',
              style: WebTextStyles.subtitle.copyWith(
                color: WebColors.greenPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Title
          Text(
            'How Accel-O-Rot Works',
            textAlign: TextAlign.center,
            style: WebTextStyles.h2.copyWith(
              fontSize: width > 768 ? 44 : 34,
              fontWeight: FontWeight.w800,
              color: WebColors.textTitle,
            ),
          ),

          const SizedBox(height: 16),

          // Subtitle
          SizedBox(
            width: 720,
            child: Text(
              'Our smart composting system transforms your organic waste into garden-ready compost with minimal effort. Just add waste and let technology handle the rest.',
              textAlign: TextAlign.center,
              style: WebTextStyles.subtitle.copyWith(
                height: 1.6,
                color: const Color(0xFF64748B),
              ),
            ),
          ),

          const SizedBox(height: 64),

          // Cards
          LayoutBuilder(
            builder: (context, constraints) {
              int count = constraints.maxWidth > 1200
                  ? 4
                  : constraints.maxWidth > 900
                      ? 3
                      : constraints.maxWidth > 600
                          ? 2
                          : 1;

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: steps.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: count,
                  mainAxisSpacing: 32,
                  crossAxisSpacing: 32,
                  childAspectRatio: 1.15,
                ),
                itemBuilder: (context, index) {
                  return _AnimatedStepCard(
                    delay: Duration(milliseconds: 120 * index),
                    child: StepCard(step: steps[index]),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class _AnimatedStepCard extends StatefulWidget {
  final Duration delay;
  final Widget child;

  const _AnimatedStepCard({
    required this.delay,
    required this.child,
  });

  @override
  State<_AnimatedStepCard> createState() => _AnimatedStepCardState();
}

class _AnimatedStepCardState extends State<_AnimatedStepCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _offset;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _scale = Tween(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _offset = Tween(begin: 24.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    Future.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, child) {
        return Transform.translate(
          offset: Offset(0, _offset.value),
          child: Transform.scale(scale: _scale.value, child: child),
        );
      },
      child: widget.child,
    );
  }
}
