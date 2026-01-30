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
      height: 260, // same behavior as FeaturesSection
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
          // STEP NUMBER
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

          // TITLE
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

          // DESCRIPTION
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
