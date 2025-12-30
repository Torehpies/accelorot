// lib/ui/landing_page/widgets/impact_stat_card.dart

import 'package:flutter/material.dart';
import '../../core/constants/spacing.dart';
import '../../core/themes/web_text_styles.dart';
import '../../core/themes/web_colors.dart';
import '../models/impact_stat_model.dart';

class ImpactStatCard extends StatelessWidget {
  final ImpactStatModel stat;

  const ImpactStatCard({
    super.key,
    required this.stat,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xxxl),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: WebColors.divider),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            stat.value,
            textAlign: TextAlign.center,
            style: WebTextStyles.h1.copyWith(
              fontSize: 48,
              color: WebColors.tealAccent,
              height: 1.1,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            stat.label,
            textAlign: TextAlign.center,
            style: WebTextStyles.bodyMediumGray.copyWith(
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}