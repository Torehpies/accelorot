// lib/ui/landing_page/widgets/app_header.dart

import 'package:flutter/material.dart';
import 'package:flutter_application_1/ui/core/themes/app_theme.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/constants/spacing.dart';
import '../../core/themes/web_text_styles.dart';
import '../../core/ui/primary_button.dart';
import '../../core/ui/second_button.dart';

class AppHeader extends StatelessWidget {
  final VoidCallback onLogin;
  final VoidCallback onGetStarted;

  const AppHeader({
    super.key,
    required this.onLogin,
    required this.onGetStarted,
  });

  @override
  Widget build(BuildContext context) {
    final h2Style = WebTextStyles.h2;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFE0F2FE),
            Color(0xFFCCFBF1),
          ],
        ),
      ),
      child: Row(
        children: [
          // Logo + Text
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
							const SizedBox(width: 10),
              SvgPicture.asset(
                'assets/images/Accel-O-Rot Logo.svg',
                width: 40,
                height: 40,
                // fit: BoxFit.contain,
                semanticsLabel: 'Accel-O-Rot Logo',
              ),
							const SizedBox(width: 10),
              Text(
                'ACCEL-O-ROT',
                style: h2Style.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w900,
                  fontSize: 28,
                ),
              ),
            ],
          ),
          const Spacer(),
          // Actions
          Row(
            children: [
              SizedBox(
                height: 50,
                child: SecondaryButton(
                  text: 'Login',
                  onPressed: onLogin,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              SizedBox(
                height: 50,
                child: PrimaryButton(
                  text: 'Get Started',
                  onPressed: onGetStarted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
