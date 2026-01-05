// lib/ui/landing_page/widgets/cta_section.dart

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/constants/spacing.dart';
import '../../core/themes/web_text_styles.dart';
import '../../core/themes/web_colors.dart';

class CtaSection extends StatelessWidget {
  final VoidCallback onGetStarted;
  const CtaSection({
    super.key,
    required this.onGetStarted,
  });

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
                colors: [
                  Color(0xFF0D9488),
                  Color(0xFF14B8A6),
                ],
              ),
            ),
            child: Column(
              children: [
                Text(
                  'Ready to Transform Your Waste\nManagement?',
                  textAlign: TextAlign.center,
                  style: WebTextStyles.h1.copyWith(
                    color: Colors.white,
                    fontSize: 40,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  'Join the sustainable composting revolution with Accel-O-Rot\'s smart IoT\nsystem',
                  textAlign: TextAlign.center,
                  style: WebTextStyles.subtitle.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxxl),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: onGetStarted,
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 14,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Get Started Today',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: WebColors.tealAccent,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              Icons.arrow_forward,
                              size: 18,
                              color: WebColors.tealAccent,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Footer with SVG logo
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.xxxl),
            color: Colors.white,
            child: Row(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      'assets/images/Accel-O-Rot Logo.svg',
                      width: 80,
                      height: 80,
                      fit: BoxFit.contain,
                      semanticsLabel: 'Accel-O-Rot Logo',
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Text(
                      'Accel-O-Rot',
                      style: WebTextStyles.h2.copyWith(
                        color: WebColors.tealAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                // Wrap the copyright text in a Flexible widget
                Flexible(
                  child: Text(
                    '© 2026 Accel-O-Rot. Accelerating sustainable composting through innovation.',
                    style: WebTextStyles.caption,
                    textAlign: TextAlign.right, // Align text to the right
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}