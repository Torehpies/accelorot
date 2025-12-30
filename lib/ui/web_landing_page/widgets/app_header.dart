// lib/ui/landing_page/widgets/app_header.dart

import 'package:flutter/material.dart';
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
        vertical: AppSpacing.lg,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: WebColors.divider, width: 1),
        ),
      ),
      child: Row(
        children: [
          // Logo
          Row(
            children: [
              Image.asset(
                'assets/images/Accel-O-Rot Logo.png',
                width: 80,
                height: 80,
                fit: BoxFit.contain,
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