// lib/ui/landing_page/widgets/cta_section.dart

import 'package:flutter/material.dart';
//import 'package:flutter_application_1/ui/core/themes/app_theme.dart';

import 'package:flutter_svg/flutter_svg.dart';
import '../../core/constants/spacing.dart';
import '../../core/themes/web_text_styles.dart';
import '../../core/themes/web_colors.dart';

class CtaSection extends StatelessWidget {
  final VoidCallback onGetStarted;

  const CtaSection({super.key, required this.onGetStarted});

  @override
  Widget build(BuildContext context) {
    final h2Style = WebTextStyles.h2;

    return SizedBox(
      width: double.infinity,
      child: Column(
        children: [
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
                    color: Color(0xFF111827),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxxl),
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
            padding: const EdgeInsets.all(AppSpacing.lg),
            color: Colors.white,
            child: Row(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(width: 10),
                    SvgPicture.asset(
                      'assets/images/Accel-O-Rot Logo.svg',
                      width: 50,
                      height: 50,
                      fit: BoxFit.contain,
                      semanticsLabel: 'Accel-O-Rot Logo',
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'ACCEL-O-ROT',
                      style: h2Style.copyWith(
                        color: WebColors.textTitle,
                        fontWeight: FontWeight.w900,
                        fontSize: 28,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Flexible(
                  child: Text(
                    '© 2026 Accel-O-Rot. Accelerating sustainable composting through innovation.',
                    style: WebTextStyles.caption,
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
