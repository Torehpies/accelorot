// lib/ui/landing_page/widgets/app_header.dart

import 'package:flutter/material.dart';
import 'package:flutter_application_1/ui/core/themes/app_theme.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/constants/spacing.dart';
import '../../core/themes/web_text_styles.dart';
import '../../core/themes/web_colors.dart';
import '../../core/ui/primary_button.dart';
import '../../core/ui/second_button.dart';

class AppHeader extends StatelessWidget {
  final VoidCallback onLogin;
  final VoidCallback onGetStarted;
  final String? currentSection;
  final List<String>? sections;
  final Function(String)? onSectionTap;

  const AppHeader({
    super.key,
    required this.onLogin,
    required this.onGetStarted,
    this.currentSection,
    this.sections,
    this.onSectionTap,
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
        crossAxisAlignment: CrossAxisAlignment.center,
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
          
          // Breadcrumbs in the middle
          if (sections != null && currentSection != null && onSectionTap != null) ...[
            const SizedBox(width: AppSpacing.xxxl),
            Expanded(
              child: Center(
                child: Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xs,
                  alignment: WrapAlignment.center,
                  children: sections!.map((section) {
                    final isActive = section == currentSection;
                    return _SectionChip(
                      label: section,
                      isActive: isActive,
                      onTap: () => onSectionTap!(section),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.xxxl),
          ],
          
          if (sections == null || currentSection == null || onSectionTap == null)
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

// Flat Section Chip without container background
class _SectionChip extends StatefulWidget {
  final String label;
  final bool isActive;
  final VoidCallback? onTap;

  const _SectionChip({
    required this.label,
    required this.isActive,
    this.onTap,
  });

  @override
  State<_SectionChip> createState() => _SectionChipState();
}

class _SectionChipState extends State<_SectionChip> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: widget.onTap != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: widget.isActive
                ? WebColors.greenAccent
                : _isHovered
                    ? Colors.white.withValues(alpha: 0.5)
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: widget.isActive || _isHovered
                ? Border.all(
                    color: WebColors.greenAccent,
                    width: 1.5,
                  )
                : null,
          ),
          child: Text(
            widget.label,
            style: WebTextStyles.body.copyWith(
              fontSize: 13,
              fontWeight: widget.isActive ? FontWeight.w600 : FontWeight.w500,
              color: widget.isActive
                  ? Colors.white
                  : _isHovered
                      ? WebColors.textHeading
                      : WebColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
