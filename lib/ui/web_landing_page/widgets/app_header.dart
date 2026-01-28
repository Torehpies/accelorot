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
      duration: const Duration(milliseconds: 250),
      height: 88,
      decoration: BoxDecoration(
        color: isScrolled ? Colors.white : const Color(0xFFE9FAFB),
        boxShadow: isScrolled
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ]
            : [],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxxl),
        child: Row(
          children: [
            /// Logo
            GestureDetector(
              onTap: () => onBreadcrumbTap('home'),
              child: Row(
                children: [
                  SvgPicture.asset(
                    'assets/images/Accel-O-Rot Logo.svg',
                    width: 36,
                    height: 36,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Accel-O-Rot',
                    style: WebTextStyles.h3.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            /// Breadcrumb Navigation (Image-style)
            Row(
              children: [
                _BreadcrumbItem(
                  label: 'Home',
                  id: 'home',
                  active: activeSection,
                  onTap: onBreadcrumbTap,
                ),
                _Chevron(),
                _BreadcrumbItem(
                  label: 'Features',
                  id: 'features',
                  active: activeSection,
                  onTap: onBreadcrumbTap,
                ),
                _Chevron(),
                _BreadcrumbItem(
                  label: 'How It Works',
                  id: 'how-it-works',
                  active: activeSection,
                  onTap: onBreadcrumbTap,
                ),
                _Chevron(),
                _BreadcrumbItem(
                  label: 'Impact',
                  id: 'impact',
                  active: activeSection,
                  onTap: onBreadcrumbTap,
                ),
                _Chevron(),
                _BreadcrumbItem(
                  label: 'Join Us',
                  id: 'banner',
                  active: activeSection,
                  onTap: onBreadcrumbTap,
                ),
              ],
            ),

            const Spacer(),

            /// Actions
            Row(
              children: [
                TextButton(
                  onPressed: onLogin,
                  child: const Text('Login'),
                ),
                const SizedBox(width: AppSpacing.md),
                SizedBox(
                  height: 42,
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


class _BreadcrumbItem extends StatelessWidget {
  final String label;
  final String id;
  final String active;
  final Function(String) onTap;

  const _BreadcrumbItem({
    required this.label,
    required this.id,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isActive = active == id;

    return GestureDetector(
      onTap: () => onTap(id),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              color: isActive
                  ? WebColors.success // green active text
                  : WebColors.textMuted,
            ),
          ),
          const SizedBox(height: 6),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 2,
            width: isActive ? 32 : 0,
            decoration: BoxDecoration(
              color: WebColors.success,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }
}


class _Chevron extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Icon(
        Icons.chevron_right,
        size: 18,
        color: WebColors.textMuted.withOpacity(0.6),
      ),
    );
  }
}
