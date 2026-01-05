// lib/ui/landing_page/widgets/step_card.dart

import 'package:flutter/material.dart';
import '../../core/constants/spacing.dart';
import '../../core/themes/web_text_styles.dart';
import '../../core/themes/web_colors.dart';
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
      padding: const EdgeInsets.all(AppSpacing.xxxl),
      decoration: BoxDecoration(
        color: const Color(0xFFE0F2FE).withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '0${step.number}',
            style: WebTextStyles.h1.copyWith(
              fontSize: 64,
              color: WebColors.tealAccent.withValues(alpha: 0.3),
              height: 1,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            step.title,
            style: WebTextStyles.h3.copyWith(fontSize: 18),
          ),
          const SizedBox(height: AppSpacing.sm),
          Flexible(
            child: Text(
              step.description,
              softWrap: true,
              maxLines: 3,
              overflow: TextOverflow.ellipsis, // Or fade if you prefer
              style: WebTextStyles.bodyMediumGray.copyWith(
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}