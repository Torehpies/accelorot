// lib/ui/landing_page/widgets/cta_section.dart

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/constants/spacing.dart';
import '../../core/themes/web_text_styles.dart';
import '../../core/themes/web_colors.dart';

class CtaSection extends StatelessWidget {
  final VoidCallback onGetStarted;
  final VoidCallback? onDownload;

  const CtaSection({
    super.key,
    required this.onGetStarted,
    this.onDownload,
  });

  @override
  Widget build(BuildContext context) {
    final h2Style = WebTextStyles.h2;

    return SizedBox(
      width: double.infinity,
      child: Column(
        children: [
          // ================= CTA CONTAINER WITH GRADIENT =================
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
                  Color(0xFF84FAB0), // start green
                  Color(0xFF8FD3F4), // end blue
                ],
              ),
            ),
            child: Column(
              children: [
                Text(
                  'Ready to Transform Your Waste\nManagement?',
                  textAlign: TextAlign.center,
                  style: WebTextStyles.h1.copyWith(
                    color: WebColors.textTitle,
                    fontSize: 40,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  'Join the sustainable composting revolution with Accel-O-Rot\'s smart IoT\nsystem',
                  textAlign: TextAlign.center,
                  style: WebTextStyles.subtitle.copyWith(
                    color: const Color(0xFF111827),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxxl),
                // ================= GET STARTED BUTTON =================
                Container(
                  decoration: BoxDecoration(
                    color: WebColors.iconsPrimary,
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
                                color: WebColors.textbutton2,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              Icons.arrow_forward,
                              size: 18,
                              color: WebColors.textbutton2,
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
          // Footers
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xxxl * 2,
              vertical: AppSpacing.xl,
            ),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
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
                      style: h2Style.copyWith(
                        color: WebColors.textTitle,
                        fontWeight: FontWeight.w900,
                        fontSize: 24,
                      ),
                    ),
                  ],
                ),
                Flexible(
                  child: Text(
                    '© 2026 Accel-O-Rot. Accelerating sustainable composting through innovation.',
                    style: WebTextStyles.caption.copyWith(
                      color: const Color(0xFF6B7280),
                      fontSize: 13,
                    ),
                    textAlign: TextAlign.right,
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