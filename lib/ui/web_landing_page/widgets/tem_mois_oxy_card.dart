// lib/ui/landing_page/widgets/tem_mois_oxy_card.dart

import 'package:flutter/material.dart';
import '../../core/constants/spacing.dart';
import '../../core/themes/web_text_styles.dart';

class TemMoisOxyCard extends StatefulWidget {
  final IconData icon;
  final String value;
  final String label;
  final String? hoverInfo;
  final int position;

  const TemMoisOxyCard({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    this.hoverInfo,
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
  bool _isTapped = false; // For mobile touch feedback

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    // Staggered entrance animation based on position
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

  void _handleTap() {
    setState(() {
      _isTapped = !_isTapped;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Determine if this is a mobile/small screen
        final isMobile = constraints.maxWidth < 200;
        final isActive = _isHovered || _isTapped;

        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              onEnter: (_) => setState(() => _isHovered = true),
              onExit: (_) => setState(() => _isHovered = false),
              child: GestureDetector(
                onTap: widget.hoverInfo != null ? _handleTap : null,
                child: AnimatedBuilder(
                  animation: Listenable.merge([_glowAnimation]),
                  builder: (context, child) {
                    // Zoom scale: 1.0 normal, 1.02 on hover/tap
                    final scale = isActive ? 1.02 : 1.0;

                    // Glow logic
                    final glowIntensity = isActive
                        ? 0.4 + (_glowAnimation.value * 0.3)
                        : 0.0 + (_glowAnimation.value * 0.1);

                    final shadowOpacity = glowIntensity * 0.15;
                    final shadowBlur = 8.0 + (glowIntensity * 8.0);

                    // Responsive sizing
                    final iconSize = isMobile ? 24.0 : 28.0;
                    final valueSize = isMobile ? 22.0 : 28.0;
                    final labelSize = isMobile ? 11.0 : 13.0;
                    final hoverInfoSize = isMobile ? 10.0 : 12.0;
                    final padding = isMobile ? AppSpacing.lg : AppSpacing.xl;

                    return AnimatedScale(
                      scale: scale,
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeOutCubic,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeOutCubic,
                        padding: EdgeInsets.all(padding),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              const Color(0xFFDEF9F4).withValues(
                                alpha: isActive ? 1.0 : 0.9,
                              ),
                              const Color(0xFFC0F0E0).withValues(
                                alpha: isActive ? 0.8 : 0.6,
                              ),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
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
                              color: Colors.black.withValues(alpha: 0.02),
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
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.easeOutCubic,
                              width: isMobile ? 36 : 44,
                              height: isMobile ? 36 : 44,
                              decoration: BoxDecoration(
                                color: isActive
                                    ? const Color(0xFF10B981).withValues(alpha: 0.08)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(isMobile ? 8 : 10),
                                boxShadow: [
                                  if (isActive)
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
                                size: iconSize,
                                color: const Color(0xFF10B981),
                              ),
                            ),
                            SizedBox(height: isMobile ? AppSpacing.sm : AppSpacing.md),
                            Text(
                              widget.value,
                              style: WebTextStyles.h2.copyWith(
                                color: const Color(0xFF111827),
                                fontSize: valueSize,
                                fontWeight: FontWeight.bold,
                                height: 1.0,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              widget.label,
                              style: WebTextStyles.caption.copyWith(
                                color: const Color(0xFF6B7280),
                                fontSize: labelSize,
                              ),
                            ),
                            // Show additional info on hover or tap
                            if (widget.hoverInfo != null)
                              AnimatedSize(
                                duration: const Duration(milliseconds: 400),
                                curve: Curves.easeOutCubic,
                                child: AnimatedOpacity(
                                  duration: const Duration(milliseconds: 400),
                                  curve: Curves.easeInOut,
                                  opacity: isActive ? 1.0 : 0.0,
                                  child: isActive
                                      ? Padding(
                                          padding: EdgeInsets.only(
                                            top: isMobile ? 8 : 12,
                                          ),
                                          child: Text(
                                            widget.hoverInfo!,
                                            style: WebTextStyles.caption.copyWith(
                                              color: const Color(0xFF6B7280),
                                              fontSize: hoverInfoSize,
                                              height: 1.4,
                                            ),
                                          ),
                                        )
                                      : const SizedBox.shrink(),
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
          ),
        );
      },
    );
  }
}