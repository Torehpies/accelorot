// lib/ui/landing_page/widgets/cta_section.dart

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/constants/spacing.dart';
import '../../core/themes/web_text_styles.dart';
import '../../core/themes/web_colors.dart';

class CtaSection extends StatefulWidget {
  final VoidCallback onGetStarted;

  const CtaSection({super.key, required this.onGetStarted});

  @override
  State<CtaSection> createState() => _CtaSectionState();
}

class _CtaSectionState extends State<CtaSection> {
  bool _isButtonHovered = false;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        children: [
          // CTA Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xxxl * 2,
              vertical: AppSpacing.xxxl * 3,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFE0F2FE), Color(0xFFCCFBF1)],
              ),
            ),
            child: Column(
              children: [
                Text(
                  'Ready to Transform Your Waste\nManagement?',
                  textAlign: TextAlign.center,
                  style: WebTextStyles.h1.copyWith(
                    color: WebColors.textHeading,
                    fontSize: 44,
                    fontWeight: FontWeight.bold,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Join the sustainable composting revolution with Accel-O-Rot\'s smart IoT system',
                  textAlign: TextAlign.center,
                  style: WebTextStyles.subtitle.copyWith(
                    color: WebColors.textSecondary,
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxxl),
                // Animated CTA Button
                MouseRegion(
                  onEnter: (_) => setState(() => _isButtonHovered = true),
                  onExit: (_) => setState(() => _isButtonHovered = false),
                  cursor: SystemMouseCursors.click,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    transform: Matrix4.diagonal3Values(
                      _isButtonHovered ? 1.05 : 1.0,
                      _isButtonHovered ? 1.05 : 1.0,
                      1.0,
                    ),
                    decoration: BoxDecoration(
                      gradient: _isButtonHovered
                          ? LinearGradient(
                              colors: [
                                WebColors.greenAccent,
                                WebColors.greenAccent.withValues(alpha: 0.8),
                              ],
                            )
                          : null,
                      color: _isButtonHovered ? null : WebColors.greenAccent,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: _isButtonHovered
                          ? [
                              BoxShadow(
                                color: WebColors.greenAccent.withValues(alpha: 0.4),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ]
                          : [
                              BoxShadow(
                                color: WebColors.greenAccent.withValues(alpha: 0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: widget.onGetStarted,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 18,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Get Started Today',
                                style: WebTextStyles.buttonText.copyWith(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Icon(
                                Icons.arrow_forward,
                                size: 20,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Footer
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xxxl,
              vertical: AppSpacing.xl,
            ),
            color: Colors.white,
            child: LayoutBuilder(
              builder: (context, constraints) {
                bool isMobile = constraints.maxWidth < 768;
                
                if (isMobile) {
                  return Column(
                    children: [
                      _buildLogoSection(),
                      const SizedBox(height: AppSpacing.md),
                      _buildCopyright(),
                    ],
                  );
                }
                
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildLogoSection(),
                    Flexible(
                      child: _buildCopyright(),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoSection() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SvgPicture.asset(
          'assets/images/Accel-O-Rot Logo.svg',
          width: 50,
          height: 50,
          fit: BoxFit.contain,
          semanticsLabel: 'Accel-O-Rot Logo',
        ),
        const SizedBox(width: AppSpacing.md),
        Text(
          'ACCEL-O-ROT',
          style: WebTextStyles.h2.copyWith(
            color: WebColors.textHeading,
            fontWeight: FontWeight.w900,
            fontSize: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildCopyright() {
    return Text(
      '© 2026 Accel-O-Rot. Accelerating sustainable composting through innovation.',
      style: WebTextStyles.caption.copyWith(
        fontSize: 13,
        color: WebColors.textMuted,
      ),
      textAlign: TextAlign.right,
    );
  }
}
