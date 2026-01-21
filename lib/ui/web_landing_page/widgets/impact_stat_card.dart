// lib/ui/landing_page/widgets/impact_stat_card.dart

import 'package:flutter/material.dart';
import '../../core/constants/spacing.dart';
import '../../core/themes/web_text_styles.dart';
import '../../core/themes/web_colors.dart';
import '../models/impact_stat_model.dart';

class ImpactStatCard extends StatefulWidget {
  final ImpactStatModel stat;
  const ImpactStatCard({
    super.key,
    required this.stat,
  });

  @override
  State<ImpactStatCard> createState() => _ImpactStatCardState();
}

class _ImpactStatCardState extends State<ImpactStatCard> {
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
        transform: Matrix4.translationValues(0.0, _isHovered ? -6.0 : 0.0, 0.0),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.xl,
        ),
        decoration: BoxDecoration(
          gradient: _isHovered
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    WebColors.greenAccent.withValues(alpha: 0.15),
                    WebColors.greenAccent.withValues(alpha: 0.05),
                  ],
                )
              : null,
          color: _isHovered ? null : WebColors.greenAccent.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _isHovered 
                ? WebColors.greenAccent 
                : WebColors.greenAccent.withValues(alpha: 0.3),
            width: _isHovered ? 2 : 1.5,
          ),
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    color: WebColors.greenAccent.withValues(alpha: 0.2),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ]
              : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: WebTextStyles.impactStatValue.copyWith(
                fontSize: _isHovered ? 42 : 38,
                fontWeight: FontWeight.bold,
                color: WebColors.greenAccent,
                height: 1.1,
              ),
              child: Text(
                widget.stat.value,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              widget.stat.label,
              textAlign: TextAlign.center,
              style: WebTextStyles.impactStatLabel.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: WebColors.textSecondary,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
