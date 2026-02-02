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
        color: isScrolled ? Colors.white : const Color(0xFFE0F2FE),
        border: isScrolled
            ? const Border(
                bottom: BorderSide(
                  color: Color(0xFFE5E7EB),
                  width: 1,
                ),
              )
            : null,
        boxShadow: isScrolled
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 16,
                  spreadRadius: 0,
                  offset: const Offset(0, 4),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  spreadRadius: 0,
                  offset: const Offset(0, 2),
                ),
              ]
            : [],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxxl),
        child: Row(
          children: [
            /// Logo - UPDATED to match ContactSection style
            GestureDetector(
              onTap: () => onBreadcrumbTap('home'),
              child: Row(
                children: [
                  SvgPicture.asset(
                    'assets/images/Accel-O-Rot Logo.svg',
                    width: 50, // Increased from 36 to match ContactSection
                    height: 50, // Increased from 36 to match ContactSection
                    fit: BoxFit.contain,
                    semanticsLabel: 'Accel-O-Rot Logo',
                  ),
                  const SizedBox(width: AppSpacing.md), // Changed from 10 to AppSpacing.md
                  Text(
                    'Accel-O-Rot',
                    style: WebTextStyles.h2.copyWith( // Changed from h3 to h2
                      color: WebColors.buttonsPrimary, // Changed to green
                      fontWeight: FontWeight.w900, // Changed from w800 to w900
                      fontSize: 24, // Explicit font size
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            /// Breadcrumb Navigation — LARGER TEXT & ICONS
            Row(
              children: [
                _BreadcrumbItem(
                  label: 'Home',
                  id: 'home',
                  active: activeSection,
                  onTap: onBreadcrumbTap,
                ),
                _Chevron(size: 20),
                _BreadcrumbItem(
                  label: 'Features',
                  id: 'features',
                  active: activeSection,
                  onTap: onBreadcrumbTap,
                ),
                _Chevron(size: 20),
                _BreadcrumbItem(
                  label: 'How It Works',
                  id: 'how-it-works',
                  active: activeSection,
                  onTap: onBreadcrumbTap,
                ),
                _Chevron(size: 20),
                _BreadcrumbItem(
                  label: 'Impact',
                  id: 'impact',
                  active: activeSection,
                  onTap: onBreadcrumbTap,
                ),
                _Chevron(size: 20),
                _BreadcrumbItem(
                  label: 'Downloads',
                  id: 'download',
                  active: activeSection,
                  onTap: onBreadcrumbTap,
                ),
                _Chevron(size: 20),
                _BreadcrumbItem(
                  label: 'FAQs',
                  id: 'faq',
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
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 16, 
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
            color: isActive
                ? WebColors.success
                : const Color(0xFF6B7280),
          ),
        ),
      ),
    );
  }
}

class _Chevron extends StatelessWidget {
  final double size;

  const _Chevron({this.size = 16});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Icon(
        Icons.chevron_right,
        size: size, 
        color: const Color(0xFF9CA3AF),
      ),
    );
  }
}