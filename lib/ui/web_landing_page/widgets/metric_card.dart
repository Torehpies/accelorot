// lib/ui/landing_page/widgets/metrics_card.dart

import 'package:flutter/material.dart';
import '../../core/themes/web_colors.dart';
import '../../core/themes/web_text_styles.dart';
import '../../core/constants/spacing.dart';



class MetricsCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color? backgroundColor;

  const MetricsCard({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: WebColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 32,
            color: WebColors.tealAccent,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            value,
            style: WebTextStyles.h2.copyWith(
              color: WebColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            label,
            style: WebTextStyles.bodyMediumGray,
          ),
        ],
      ),
    );
  }
}