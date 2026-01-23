// lib/ui/landing_page/widgets/step_card.dart

import 'package:flutter/material.dart';
import '../../core/constants/spacing.dart';
import '../../core/themes/web_text_styles.dart';
import '../models/step_model.dart';

class StepCard extends StatelessWidget {
  final StepModel step;
  final bool enableHover;

  const StepCard({
    super.key,
    required this.step,
    this.enableHover = true, // new: hover effect for desktop
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final numberFontSize = screenWidth > 1200
        ? 48.0
        : screenWidth > 900
            ? 42.0
            : 32.0; // responsive sizes

    Widget cardContent = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          '${step.number}',
          style: WebTextStyles.stepNumber.copyWith(fontSize: numberFontSize),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          step.title,
          textAlign: TextAlign.center,
          style: WebTextStyles.stepCardTitle,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          step.description,
          textAlign: TextAlign.center,
          style: WebTextStyles.stepCardDescription,
        ),
      ],
    );

    // Desktop hover effect
    if (enableHover && screenWidth > 900) {
      cardContent = MouseRegion(
        cursor: SystemMouseCursors.click,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 248, 247, 247),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFBAE6FD),
              width: 1,
            ),
          ),
          padding: EdgeInsets.all(AppSpacing.xl),
          child: cardContent,
        ),
      );
    } else {
      cardContent = Container(
        padding: EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 248, 247, 247),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFBAE6FD),
            width: 1,
          ),
        ),
        child: cardContent,
      );
    }

    return cardContent;
  }
}
