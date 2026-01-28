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
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: 96,
      decoration: BoxDecoration(
      color: isScrolled ? Colors.white : Colors.transparent,
      boxShadow: isScrolled
          ? [
              BoxShadow(
                blurRadius: 12,
                offset: const Offset(0, 4),
                color: Colors.black.withValues(alpha: 0.08),
              )
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
            GestureDetector(
              onTap: () => onBreadcrumbTap('home'),
              child: Row(
                children: [
                  SvgPicture.asset(
                    'assets/images/Accel-O-Rot Logo.svg',
                    width: 40,
                    height: 40,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Accel-O-Rot',
                    style: WebTextStyles.h2.copyWith(
                      fontSize: 25,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            Row(
              children: [
                _NavItem('Home', 'home', activeSection, onBreadcrumbTap),
                _NavItem('Features', 'features', activeSection, onBreadcrumbTap),
                _NavItem('How It Works', 'how-it-works', activeSection, onBreadcrumbTap),
                _NavItem('Impact', 'impact', activeSection, onBreadcrumbTap),
                _NavItem('Join Us', 'banner', activeSection, onBreadcrumbTap),
              ],
            ),

            const Spacer(),

            Row(
              children: [
                TextButton(onPressed: onLogin, child: const Text('Login')),
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

class _NavItem extends StatelessWidget {
  final String label;
  final String id;
  final String active;
  final Function(String) onTap;

  const _NavItem(this.label, this.id, this.active, this.onTap);

  @override
  Widget build(BuildContext context) {
    final isActive = active == id;

    return GestureDetector(
      onTap: () => onTap(id),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(
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
              color: WebColors.iconsPrimary,
            ),
          ],
        ),
      ),
    );
  }
}
