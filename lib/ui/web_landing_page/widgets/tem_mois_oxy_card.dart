// lib/ui/landing_page/widgets/tem_mois_oxy_card.dart

import 'package:flutter/material.dart';
import '../../core/constants/spacing.dart';
import '../../core/themes/web_text_styles.dart';

class TemMoisOxyCard extends StatefulWidget {
  final IconData icon;
  final String value;
  final String label;

  const TemMoisOxyCard({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  State<TemMoisOxyCard> createState() => _TemMoisOxyCardState();
}

class _TemMoisOxyCardState extends State<TemMoisOxyCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFFDEF9F4),
                const Color(0xFFE8F5E9).withValues(alpha: 0.5),
              ],
              stops: [
                _animationController.value,
                _animationController.value + 0.5,
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFB2DFD3), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(widget.icon, size: 32, color: const Color(0xFF10B981)),
              const SizedBox(height: AppSpacing.md),
              Text(
                widget.value,
                style: WebTextStyles.h2.copyWith(
                  color: const Color(0xFF111827),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                widget.label,
                style: WebTextStyles.caption.copyWith(
                  color: const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
