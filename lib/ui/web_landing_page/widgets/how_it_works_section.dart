// lib/ui/landing_page/widgets/how_it_works_section.dart

import 'package:flutter/material.dart';
import '../../core/constants/spacing.dart';
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
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth > 1400
            ? AppSpacing.xxxl * 1.5
            : AppSpacing.xxxl,
        vertical: AppSpacing.xl * 1.2,
      ),
      color: const Color.fromARGB(255, 204, 251, 241), // <-- SAME COLOR AS YOUR ORIGINAL CODE
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Gradient title - SAME AS YOUR ORIGINAL
          ShaderMask(
            shaderCallback: (Rect bounds) {
              return LinearGradient(
                colors: [WebColors.buttonsPrimary, WebColors.greenLight],
                stops: const [0.3, 1.0],
              ).createShader(bounds);
            },
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: WebTextStyles.h2.copyWith(
                  fontSize: screenWidth > 768 ? 42 : 32,
                  fontWeight: FontWeight.bold,
                  shadows: const [
                    Shadow(
                      offset: Offset(0, 2),
                      blurRadius: 8,
                      color: Color.fromARGB(20, 0, 0, 0),
                    ),
                  ],
                ),
                children: [
                  const TextSpan(text: 'How '),
                  TextSpan(
                    text: 'Accel-O-Rot',
                    style: WebTextStyles.h2.copyWith(
                      fontSize: screenWidth > 768 ? 42 : 32,
                      fontWeight: FontWeight.bold,
                      foreground: Paint()..color = WebColors.textTitle,
                    ),
                  ),
                  const TextSpan(text: ' Works'),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          
          // Subtitle - SAME AS YOUR ORIGINAL
          Text(
            'Simple, automated, and effective composting in 4 easy steps',
            textAlign: TextAlign.center,
            style: WebTextStyles.subtitle.copyWith(
              fontSize: 15,
              color: const Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          
          // Grid Layout - KATULAD NG NASA IMAHE (4 columns sa malaking screen)
          LayoutBuilder(
            builder: (context, constraints) {
              int crossAxisCount = constraints.maxWidth > 1200
                  ? 4 // <-- 4 COLUMNS TULAD NG NASA IMAHE
                  : constraints.maxWidth > 900
                      ? 3
                      : constraints.maxWidth > 600
                          ? 2
                          : 1;

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: AppSpacing.lg, // <-- MAS MALAKING SPACING
                  mainAxisSpacing: AppSpacing.lg,
                  childAspectRatio: 1.0, // <-- SQUARE CARDS TULAD NG NASA IMAHE
                ),
                itemCount: steps.length,
                itemBuilder: (context, index) {
                  return SizedBox(
                    width: 280, // <-- MAS MALAKING WIDTH PARA MAS MALAPIT SA IMAHE
                    height: 280, // <-- SQUARE HEIGHT
                    child: _AnimatedStepCard(
                      delay: Duration(milliseconds: 120 * index),
                      child: StepCard(step: steps[index]),
                    ),
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

/// Entrance animation using only Transform
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
  late AnimationController _controller;
  late Animation<double> _scale;
  late Animation<double> _offset;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _scale = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOutQuart),
      ),
    );

    _offset = Tween<double>(begin: 16, end: 0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOutQuart),
      ),
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
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _offset.value),
          child: Transform.scale(
            scale: _scale.value,
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}