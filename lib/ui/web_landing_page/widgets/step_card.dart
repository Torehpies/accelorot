// lib/ui/landing_page/widgets/step_card.dart

import 'package:flutter/material.dart';
import '../../core/constants/spacing.dart';
import '../../core/themes/web_text_styles.dart';
import '../models/step_model.dart';

class StepCard extends StatelessWidget {
  final StepModel step;

  const StepCard({
    super.key,
    required this.step,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        // ✅ SAME background as HowItWorksSection
        color: const Color.fromARGB(255, 204, 251, 241),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color.fromARGB(255, 118, 230, 207), // subtle border, still visible
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            '${step.number}',
            style: WebTextStyles.stepNumber,
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
      ),
    );
  }
}
