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
    return LayoutBuilder(
      builder: (context, constraints) {
        // Determine screen size category
        final screenWidth = MediaQuery.of(context).size.width;
        final isMobile = screenWidth < 600;
        final isTablet = screenWidth >= 600 && screenWidth < 1024;
        
        // Responsive sizing
        final horizontalPadding = isMobile 
            ? AppSpacing.md 
            : isTablet 
                ? AppSpacing.lg 
                : AppSpacing.xl;
        
        final verticalPadding = isMobile 
            ? AppSpacing.lg 
            : isTablet 
                ? AppSpacing.xl 
                : AppSpacing.xl * 1.2;
        
        final valueFontSize = isMobile 
            ? 28.0 
            : isTablet 
                ? 32.0 
                : 36.0;
        
        final labelFontSize = isMobile 
            ? 11.0 
            : isTablet 
                ? 11.5 
                : 12.0;

        return MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: verticalPadding,
            ),
            decoration: BoxDecoration(
              color: WebColors.featurecard.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: WebColors.featurecard),
              boxShadow: [
                BoxShadow(
                  color: const Color.fromARGB(38, 0, 0, 0),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                  spreadRadius: 1,
                ),
                BoxShadow(
                  color: const Color.fromARGB(13, 0, 0, 0),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  stat.value,
                  textAlign: TextAlign.center,
                  style: WebTextStyles.impactStatValue.copyWith(
                    fontSize: valueFontSize,
                    height: 1.1,
                  ),
                ),
                SizedBox(height: isMobile ? AppSpacing.xs : AppSpacing.sm),
                Flexible(
                  child: Text(
                    stat.label,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: WebTextStyles.impactStatLabel.copyWith(
                      fontSize: labelFontSize,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
