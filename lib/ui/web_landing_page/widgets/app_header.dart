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
  final VoidCallback onDownload;
  final Function(String) onBreadcrumbTap;
  final String activeSection;

  const AppHeader({
    super.key,
    required this.onLogin,
    required this.onGetStarted,
    required this.onDownload,
    required this.onBreadcrumbTap,
    required this.activeSection,
  });

  @override
  Widget build(BuildContext context) {
    final h2Style = WebTextStyles.h2;

    return SizedBox(
     height: 106, 
      child: Container(
      width: double.infinity,
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
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xxxl,
          vertical: AppSpacing.lg,
        ),
        child: Row(
          children: [
            // Logo + Brand Name
            GestureDetector(
              onTap: () => onBreadcrumbTap('home'),
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      'assets/images/Accel-O-Rot Logo.svg',
                      width: 40,
                      height: 40,
                      semanticsLabel: 'Accel-O-Rot Logo',
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'ACCEL-O-ROT',
                      style: h2Style.copyWith(
                        color: WebColors.iconsPrimary,
                        fontWeight: FontWeight.w900,
                        fontSize: 22,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            // Center-Aligned Breadcrumbs
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Row(
                children: [
                  _BreadcrumbItem(
                    label: 'Home',
                    isActive: activeSection == 'home',
                    onTap: () => onBreadcrumbTap('home'),
                  ),
                  _BreadcrumbDivider(),
                  _BreadcrumbItem(
                    label: 'Features',
                    isActive: activeSection == 'features',
                    onTap: () => onBreadcrumbTap('features'),
                  ),
                  _BreadcrumbDivider(),
                  _BreadcrumbItem(
                    label: 'How It Works',
                    isActive: activeSection == 'how-it-works',
                    onTap: () => onBreadcrumbTap('how-it-works'),
                  ),
                  _BreadcrumbDivider(),
                  _BreadcrumbItem(
                    label: 'Impact',
                    isActive: activeSection == 'impact',
                    onTap: () => onBreadcrumbTap('impact'),
                  ),
                  _BreadcrumbDivider(),
                  _BreadcrumbItem(
                    label: 'Contact',
                    isActive: activeSection == 'contact',
                    onTap: () => onBreadcrumbTap('contact'),
                  ),
                  _BreadcrumbDivider(),
                  _BreadcrumbItem(
                    label: 'Download',
                    isActive: activeSection == 'cta',
                    onTap: () => onBreadcrumbTap('cta'),
                  ),
                ],
              ),
            ),
            const Spacer(),
            // Action Buttons
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
      ),
    )
    );
  }
}

class _BreadcrumbItem extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _BreadcrumbItem({
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
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'dm-sans',
              fontSize: 14,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
              color: isActive
                  ? WebColors.textTitle
                  : WebColors.textMuted,
              decoration: TextDecoration.none,
            ),
          ),
        ),
      ),
    );
  }
}

class _BreadcrumbDivider extends StatelessWidget {
  const _BreadcrumbDivider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Icon(
        Icons.chevron_right,
        size: 16,
        color: WebColors.textMuted,
      ),
    );
  }
}