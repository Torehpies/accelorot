// lib/ui/landing_page/widgets/tem_mois_oxy_card.dart

import 'package:flutter/material.dart';
import '../../core/constants/spacing.dart';
import '../../core/themes/web_text_styles.dart';

class TemMoisOxyCard extends StatefulWidget {
  final IconData icon;
  final String value;
  final String label;
  final int position; // 0: top-left, 1: top-right, 2: bottom-left, 3: bottom-right

  const TemMoisOxyCard({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    this.position = 0,
  });

  @override
  State<TemMoisOxyCard> createState() => _TemMoisOxyCardState();
}

class _TemMoisOxyCardState extends State<TemMoisOxyCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _glowAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    // Staggered entrance animation based on position
    // 0: top-left, 1: top-right, 2: bottom-left, 3: bottom-right
    final delayFraction = (widget.position * 0.15).clamp(0.0, 0.45);

    // Fade-in animation with stagger
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(
          delayFraction,
          delayFraction + 0.4,
          curve: Curves.easeOut,
        ),
      ),
    );

    // Slide-up animation with slight bounce
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(
          delayFraction,
          delayFraction + 0.4,
          curve: Curves.easeOut,
        ),
      ),
    );

    // Continuous glow pulse animation
    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: AnimatedBuilder(
            animation: Listenable.merge([
              _glowAnimation,
            ]),
            builder: (context, child) {
              // Zoom scale: 1.0 normal, 1.03 on hover
              final scale = _isHovered ? 1.03 : 1.0;

              // Glow logic
              final glowIntensity = _isHovered
                  ? 0.4 + (_glowAnimation.value * 0.3)
                  : 0.0 + (_glowAnimation.value * 0.1);

              final shadowOpacity = glowIntensity * 0.15;
              final shadowBlur = 8.0 + (glowIntensity * 8.0);

              return Transform.scale(
                scale: scale,
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFFDEF9F4).withValues(
                          alpha: _isHovered ? 1.0 : 0.9,
                        ),
                        const Color(0xFFC0F0E0).withValues(
                          alpha: _isHovered ? 0.8 : 0.6,
                        ),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Color.lerp(
                        const Color(0xFFB2DFD3),
                        const Color(0xFF10B981),
                        glowIntensity * 0.3,
                      )!,
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF10B981)
                            .withValues(alpha: shadowOpacity),
                        blurRadius: shadowBlur,
                        spreadRadius: 1,
                        offset: const Offset(0, 4),
                      ),
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: _isHovered
                              ? const Color(0xFF10B981).withValues(alpha: 0.08)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            if (_isHovered)
                              BoxShadow(
                                color: const Color(0xFF10B981).withValues(
                                  alpha: glowIntensity * 0.15,
                                ),
                                blurRadius: shadowBlur * 0.6,
                                spreadRadius: 0,
                              ),
                          ],
                        ),
                        child: Icon(
                          widget.icon,
                          size: 28,
                          color: const Color(0xFF10B981),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        widget.value,
                        style: WebTextStyles.h2.copyWith(
                          color: const Color(0xFF111827),
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          height: 1.0,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        widget.label,
                        style: WebTextStyles.caption.copyWith(
                          color: const Color(0xFF6B7280),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}