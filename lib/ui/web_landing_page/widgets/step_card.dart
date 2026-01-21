// lib/ui/landing_page/widgets/step_card.dart

import 'package:flutter/material.dart';
import '../../core/constants/spacing.dart';
import '../../core/themes/web_text_styles.dart';
import '../../core/themes/web_colors.dart';
import '../models/step_model.dart';

class StepCard extends StatefulWidget {
  final StepModel step;
  const StepCard({
    super.key,
    required this.step,
  });

  @override
  State<StepCard> createState() => _StepCardState();
}

class _StepCardState extends State<StepCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        transform: Matrix4.translationValues(0.0, _isHovered ? -4.0 : 0.0, 0.0),
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: _isHovered 
              ? Colors.white 
              : WebColors.greenAccent.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _isHovered 
                ? WebColors.greenAccent.withValues(alpha: 0.3)
                : Colors.transparent,
            width: 2,
          ),
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    color: WebColors.greenAccent.withValues(alpha: 0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ]
              : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              '0${widget.step.number}',
              style: WebTextStyles.stepNumber.copyWith(
                fontSize: 52,
                color: WebColors.greenAccent.withValues(alpha: _isHovered ? 0.8 : 0.5),
                fontWeight: FontWeight.w300,
                height: 1.0,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              widget.step.title,
              style: WebTextStyles.stepCardTitle.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: WebColors.textHeading,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              widget.step.description,
              style: WebTextStyles.stepCardDescription.copyWith(
                fontSize: 14,
                height: 1.6,
                color: WebColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
