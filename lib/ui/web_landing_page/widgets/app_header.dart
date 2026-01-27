// lib/ui/web_landing_page/widgets/app_header.dart

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/constants/spacing.dart';
import '../../core/themes/web_text_styles.dart';
import '../../core/themes/web_colors.dart';
import '../../core/ui/primary_button.dart';

class AppHeader extends StatelessWidget {
  final VoidCallback onLogin;
  final VoidCallback onGetStarted;
  final VoidCallback onDownload;
  final Function(String) onBreadcrumbTap;
  final String activeSection;
  final bool isScrolled;

  const AppHeader({
    super.key,
    required this.onLogin,
    required this.onGetStarted,
    required this.onDownload,
    required this.onBreadcrumbTap,
    required this.activeSection,
    required this.isScrolled,
  });

  @override
  Widget build(BuildContext context) {
    final h2Style = WebTextStyles.h2;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      height: 96,
      width: double.infinity,
      decoration: BoxDecoration(
        color: isScrolled ? Colors.white : null,
        gradient: isScrolled
            ? null
            : const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFE0F2FE),
                  Color(0xFFCCFBF1),
                ],
              ),
        boxShadow: isScrolled
            ? [
                BoxShadow(
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                  color: Colors.black.withValues(alpha: 0.08),
                ),
              ]
            : [],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xxxl,
          vertical: AppSpacing.lg,
        ),
        child: Row(
          children: [
            // LOGO
            GestureDetector(
              onTap: () => onBreadcrumbTap('home'),
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Row(
                  children: [
                    SvgPicture.asset(
                      'assets/images/Accel-O-Rot Logo.svg',
                      width:  40,
                      height: 40,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Accel-O-Rot',
                      style: h2Style.copyWith(
                        fontSize: 25,
                        fontWeight: FontWeight.w800,
                        color: WebColors.textTitle,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const Spacer(),

            // NAVIGATION
            Row(
              children: [
                _NavItem(
                  label: 'Home',
                  isActive: activeSection == 'home',
                  onTap: () => onBreadcrumbTap('home'),
                ),
                _NavItem(
                  label: 'Features',
                  isActive: activeSection == 'features',
                  onTap: () => onBreadcrumbTap('features'),
                ),
                _NavItem(
                  label: 'How It Works',
                  isActive: activeSection == 'how-it-works',
                  onTap: () => onBreadcrumbTap('how-it-works'),
                ),
              
                _NavItem(
                  label: 'Impact',
                  isActive: activeSection == 'impact',
                  onTap: () => onBreadcrumbTap('impact'),
                ),
                 _NavItem(
                  label: 'Join Us',
                  isActive: activeSection == 'banner',
                  onTap: () => onBreadcrumbTap('banner'),
                ),
              ],
            ),

            const Spacer(),

            // ACTION BUTTONS
            Row(
              children: [
                TextButton(
                  onPressed: onLogin,
                  child: Text(
                    'Login',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: WebColors.textTitle,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                SizedBox(
                  height: 44,
                  child: PrimaryButton(
                    text: 'Get Started',
                    onPressed: onGetStarted,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// ----------------------
/// NAV ITEM
/// ----------------------
class _NavItem extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                  color: isActive
                      ? WebColors.iconsPrimary
                      : WebColors.textMuted,
                ),
              ),
              const SizedBox(height: 6),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 2,
                width: isActive ? 24 : 0,
                decoration: BoxDecoration(
                  color: WebColors.iconsPrimary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
