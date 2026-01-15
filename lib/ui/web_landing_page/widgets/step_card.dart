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
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF28A85A).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '0${step.number}',
            style: WebTextStyles.h1.copyWith(
              fontSize: 48,
              color: WebColors.textTitle.withValues(alpha: 0.5),
              height: 1.0,
              fontWeight: FontWeight.w300,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            step.title,
            style: WebTextStyles.h3.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              height: 1.2,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Flexible(
            child: Text(
              step.description,
              softWrap: true,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: WebTextStyles.bodyMediumGray.copyWith(
                fontSize: 13,
                height: 1.5,
                color: const Color(0xFF6B7280),
              ),
            ),
          ),
        ],
      ),
    );
  }
}