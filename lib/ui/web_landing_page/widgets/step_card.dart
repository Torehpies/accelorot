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
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
      ),
      child: Stack(
        children: [
          /// Step Number (top-right, faint)
          Positioned(
            top: 0,
            right: 0,
            child: Text(
              step.number.toString().padLeft(2, '0'),
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.w700,
                color: step.accentColor.withOpacity(0.15),
              ),
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Icon badge
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: step.accentColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  step.icon,
                  size: 28,
                  color: step.accentColor,
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              /// Title
              Text(
                step.title,
                style: WebTextStyles.stepCardTitle.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: AppSpacing.sm),

              /// Description
              Text(
                step.description,
                style: WebTextStyles.stepCardDescription.copyWith(
                  height: 1.6,
                  color: const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
