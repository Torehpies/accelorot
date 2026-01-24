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
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xxxl * 2,
        vertical: AppSpacing.xxxl * 3,
      ),
      color: Colors.white,
      child: Column(
        children: [
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: WebTextStyles.h2.copyWith(fontSize: 40),
              children: [
                const TextSpan(text: 'How '),
                TextSpan(
                  text: 'Accel-O-Rot',
                  style: WebTextStyles.h2.copyWith(
                    fontSize: 40,
                    color: WebColors.textTitle,
                  ),
                ),
                const TextSpan(text: ' Works'),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Simple, automated, and effective composting in 4 easy steps',
            textAlign: TextAlign.center,
            style: WebTextStyles.subtitle.copyWith(
              fontSize: 16,
              color: const Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: AppSpacing.xxxl * 2),
          LayoutBuilder(
            builder: (context, constraints) {
              int crossAxisCount = constraints.maxWidth > 1200 
                  ? 4 
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
                  crossAxisSpacing: AppSpacing.lg,
                  mainAxisSpacing: AppSpacing.lg,
                  childAspectRatio: 1.0,
                ),
                itemCount: steps.length,
                itemBuilder: (context, index) {
                  return StepCard(step: steps[index]);
                },
              );
            },
          ),
        ],
      ),
    );
  }
}