import 'package:flutter/material.dart';
import '../../core/constants/spacing.dart';
import '../../core/themes/web_text_styles.dart';
import '../../core/themes/web_colors.dart';
import '../models/step_model.dart';

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
      color: const Color.fromARGB(255, 204, 251, 241),
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
                  style: TextStyle(color: WebColors.textTitle),
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

          /// ✅ ALWAYS INLINE – SHRINK ONLY
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(steps.length, (index) {
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: index == steps.length - 1
                        ? 0
                        : AppSpacing.xl,
                  ),
                  child: StepCard(step: steps[index]),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

/// ===================================================
/// STEP CARD (SAME FILE → NO IMPORT ISSUES)
/// ===================================================
class StepCard extends StatelessWidget {
  final StepModel step;

  const StepCard({
    super.key,
    required this.step,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 260,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color.fromARGB(255, 240, 240, 240),
          width: 1.5,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color.fromARGB(38, 0, 0, 0),
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color.fromARGB(255, 204, 251, 241),
              border: Border.all(
                color: const Color.fromARGB(255, 118, 230, 207),
                width: 2.5,
              ),
            ),
            child: Center(
              child: Text(
                '${step.number}',
                style: WebTextStyles.stepNumber.copyWith(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF28A85A),
                ),
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          Text(
            step.title,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: WebTextStyles.stepCardTitle.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: AppSpacing.sm),

          Expanded(
            child: Text(
              step.description,
              textAlign: TextAlign.center,
              style: WebTextStyles.stepCardDescription.copyWith(
                fontSize: 13,
                height: 1.5,
                color: const Color(0xFF666666),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
