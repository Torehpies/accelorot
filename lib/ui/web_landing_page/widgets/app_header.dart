// lib/ui/landing_page/widgets/app_header.dart

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/constants/spacing.dart';
import '../../core/themes/web_text_styles.dart';
import '../../core/themes/web_colors.dart';
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
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xxxl,
        vertical: AppSpacing.md, // Reduced from lg to md
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: WebColors.divider, width: 1),
        ),
      ),
      child: Row(
        children: [
          // Logo + Text (vertically aligned)
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SvgPicture.asset(
                'assets/images/Accel-O-Rot Logo.svg',
                width: 60, // Reduced from 80 to 60
                height: 60, // Reduced from 80 to 60
                fit: BoxFit.contain,
                semanticsLabel: 'Accel-O-Rot Logo',
              ),
              const SizedBox(width: AppSpacing.md),
              Text(
                'Accel-O-Rot',
                style: WebTextStyles.h2.copyWith(
                  color: WebColors.tealAccent,
                ),
              ),
            ],
          ),
          const Spacer(),
          // Actions
          Row(
            children: [
              SecondaryButton(
                text: 'Login',
                onPressed: onLogin,
              ),
              const SizedBox(width: AppSpacing.md),
              PrimaryButton(
                text: 'Get Started',
                onPressed: onGetStarted,
              ),
            ],
          ),
        ],
      ),
    );
  }
}