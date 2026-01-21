// lib/ui/landing_page/widgets/app_header.dart
import 'package:flutter/material.dart';
import 'package:flutter_application_1/ui/core/themes/app_theme.dart';
import 'package:flutter_svg/flutter_svg.dart';
//import 'package:go_router/go_router.dart';
import '../../core/constants/spacing.dart';
import '../../core/themes/web_text_styles.dart';
import '../../core/themes/web_colors.dart';
import '../../core/ui/primary_button.dart';
import '../../core/ui/second_button.dart';

class AppHeader extends StatefulWidget {
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
  State<AppHeader> createState() => _AppHeaderState();
}

class _AppHeaderState extends State<AppHeader> {
  void _handleBreadcrumbTap(String section) {
    widget.onBreadcrumbTap(section);
  }

  @override
  Widget build(BuildContext context) {
    final h2Style = WebTextStyles.h2;

    return Container(
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
              onTap: () => _handleBreadcrumbTap('home'),
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
                        color: AppColors.textPrimary,
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
                    isActive: widget.activeSection == 'home',
                    onTap: () => _handleBreadcrumbTap('home'),
                  ),
                  _BreadcrumbDivider(),
                  _BreadcrumbItem(
                    label: 'Features',
                    isActive: widget.activeSection == 'features',
                    onTap: () => _handleBreadcrumbTap('features'),
                  ),
                  _BreadcrumbDivider(),
                  _BreadcrumbItem(
                    label: 'How It Works',
                    isActive: widget.activeSection == 'how-it-works',
                    onTap: () => _handleBreadcrumbTap('how-it-works'),
                  ),
                  _BreadcrumbDivider(),
                  _BreadcrumbItem(
                    label: 'Impact',
                    isActive: widget.activeSection == 'impact',
                    onTap: () => _handleBreadcrumbTap('impact'),
                  ),
                   _BreadcrumbDivider(),
                  _BreadcrumbItem(
                    label: 'Contact',
                    isActive: widget.activeSection == 'contact',
                    onTap: () => _handleBreadcrumbTap('contact'),
                  ),
                  _BreadcrumbDivider(),
                  _BreadcrumbItem(
                    label: 'Download',
                    isActive: widget.activeSection == 'download',
                    onTap: () => _handleBreadcrumbTap('download'),
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
                    onPressed: widget.onLogin,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                SizedBox(
                  height: 50,
                  child: PrimaryButton(
                    text: 'Get Started',
                    onPressed: widget.onGetStarted,
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
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'dm-sans',
            fontSize: 14,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
            color: isActive
                ? WebColors.textTitle
                : WebColors.textMuted,
            decoration: isActive ? TextDecoration.underline : null,
            decorationThickness: 2.5,
            decorationColor: WebColors.textTitle,
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
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Text(
        '>',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: WebColors.textMuted,
        ),
      ),
    );
  }
}
