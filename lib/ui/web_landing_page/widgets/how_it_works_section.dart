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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xxxl * 2),
      color: const Color(0xFFFAFAFA),
      child: Column(
        children: [
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: WebTextStyles.h2,
              children: [
                const TextSpan(text: 'How '),
                TextSpan(
                  text: 'Accel-O-Rot',
                  style: TextStyle(color: WebColors.tealAccent),
                ),
                const TextSpan(text: ' Works'),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Simple, automated, and effective composting in 4 easy steps',
            textAlign: TextAlign.center,
            style: WebTextStyles.subtitle,
          ),
          const SizedBox(height: AppSpacing.xxxl * 2),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: AppSpacing.xl,
              mainAxisSpacing: AppSpacing.xl,
              childAspectRatio: 0.85,
            ),
            itemCount: steps.length,
            itemBuilder: (context, index) {
              return StepCard(step: steps[index]);
            },
          ),
        ],
      ),
    );
  }
}