import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/constants/spacing.dart';
import '../../core/themes/web_text_styles.dart';
import '../../core/themes/web_colors.dart';
import '../../core/ui/primary_button.dart'; 
import '../../core/ui/header_button.dart'; 

class AppHeader extends StatefulWidget {
  final VoidCallback onLogin;
  final VoidCallback onGetStarted;
  final VoidCallback onDownload;
  final Function(String) onBreadcrumbTap;
  final String activeSection;
  final bool isScrolled;
  final VoidCallback? onMenuTap;

  const AppHeader({
    super.key,
    required this.onLogin,
    required this.onGetStarted,
    required this.onDownload,
    required this.onBreadcrumbTap,
    required this.activeSection,
    required this.isScrolled,
    this.onMenuTap,
  });

  @override
  State<AppHeader> createState() => _AppHeaderState();
}

class _AppHeaderState extends State<AppHeader> {
  bool _isLogoHovered = false;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final isTablet = screenWidth >= 768 && screenWidth < 1024;
    final isVerySmall = screenWidth < 320;

    final horizontalPadding = isVerySmall
        ? AppSpacing.sm
        : (isMobile ? AppSpacing.md : (isTablet ? AppSpacing.lg : AppSpacing.xxxl));

    final headerHeight = isMobile ? 64.0 : 88.0;
    final logoSize = isVerySmall ? 32.0 : (isMobile ? 40.0 : 50.0);
    final appNameFontSize = isVerySmall ? 16.0 : (isMobile ? 20.0 : 24.0);
    final showAppName = screenWidth > 280;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      height: headerHeight,
      width: double.infinity,
      decoration: BoxDecoration(
        color: widget.isScrolled ? Colors.white : const Color(0xFFE0F2FE),
        border: widget.isScrolled
            ? const Border(
                bottom: BorderSide(
                  color: Color(0xFFE5E7EB),
                  width: 1,
                ),
              )
            : null,
        boxShadow: widget.isScrolled
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
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Logo section with hover effect
            Flexible(
              flex: 1,
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                onEnter: (_) => setState(() => _isLogoHovered = true),
                onExit: (_) => setState(() => _isLogoHovered = false),
                child: GestureDetector(
                  onTap: () => widget.onBreadcrumbTap('home'),
                  child: AnimatedScale(
                    duration: const Duration(milliseconds: 200),
                    scale: _isLogoHovered ? 1.05 : 1.0,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          child: Image.asset(
                            'assets/images/Accelorot Logo.png',
                            width: logoSize,
                            height: logoSize,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return SvgPicture.asset(
                                'assets/images/Accelorot_logo.svg',
                                width: logoSize,
                                height: logoSize,
                                fit: BoxFit.contain,
                              );
                            },
                          ),
                        ),
                        if (showAppName) ...[
                          const SizedBox(width: AppSpacing.xs),
                          Flexible(
                            child: AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 200),
                              style: WebTextStyles.h2.copyWith(
                                color: _isLogoHovered 
                                    ? WebColors.success 
                                    : WebColors.buttonsPrimary,
                                fontWeight: FontWeight.w900,
                                fontSize: appNameFontSize,
                              ),
                              child: const Text(
                                'Accel-O-Rot',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Navigation handling based on screen size
            if (isMobile) ...[
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.onMenuTap != null) ...[
                    IconButton(
                      icon: Icon(
                        Icons.menu,
                        color: WebColors.textPrimary,
                        size: isVerySmall ? 24 : 28,
                      ),
                      onPressed: widget.onMenuTap,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      tooltip: 'Open menu',
                    ),
                    const SizedBox(width: AppSpacing.xs),
                  ],
                  SizedBox(
                    width: isVerySmall ? 90 : 110,
                    height: 32,
                    child: PrimaryButton(
                      text: isVerySmall ? 'Start' : 'Get Started',
                      onPressed: widget.onGetStarted,
                    ),
                  ),
                ],
              ),
            ] else ...[
              Flexible(
                flex: 3,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const ClampingScrollPhysics(),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _BreadcrumbItem(
                        label: 'Home',
                        id: 'home',
                        active: widget.activeSection,
                        onTap: widget.onBreadcrumbTap,
                        fontSize: isTablet ? 15 : 16,
                      ),
                      _Chevron(size: isTablet ? 18 : 20),
                      _BreadcrumbItem(
                        label: 'Features',
                        id: 'features',
                        active: widget.activeSection,
                        onTap: widget.onBreadcrumbTap,
                        fontSize: isTablet ? 15 : 16,
                      ),
                      _Chevron(size: isTablet ? 18 : 20),
                      _BreadcrumbItem(
                        label: 'How It Works',
                        id: 'how-it-works',
                        active: widget.activeSection,
                        onTap: widget.onBreadcrumbTap,
                        fontSize: isTablet ? 15 : 16,
                      ),
                      _Chevron(size: isTablet ? 18 : 20),
                      _BreadcrumbItem(
                        label: 'Impact',
                        id: 'impact',
                        active: widget.activeSection,
                        onTap: widget.onBreadcrumbTap,
                        fontSize: isTablet ? 15 : 16,
                      ),
                      _Chevron(size: isTablet ? 18 : 20),
                      _BreadcrumbItem(
                        label: 'Downloads',
                        id: 'download',
                        active: widget.activeSection,
                        onTap: widget.onBreadcrumbTap,
                        fontSize: isTablet ? 15 : 16,
                      ),
                      _Chevron(size: isTablet ? 18 : 20),
                      _BreadcrumbItem(
                        label: 'FAQs',
                        id: 'faq',
                        active: widget.activeSection,
                        onTap: widget.onBreadcrumbTap,
                        fontSize: isTablet ? 15 : 16,
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ✅ ONLY THIS BUTTON IS NOW HeaderButton
                  SizedBox(
                    width: 100,
                    height: isTablet ? 38 : 42,
                    child: HeaderButton(
                      text: 'Login',
                      onPressed: widget.onLogin,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  SizedBox(
                    width: 140,
                    height: isTablet ? 38 : 42,
                    child: PrimaryButton(
                      text: 'Get Started',
                      onPressed: widget.onGetStarted,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Keep _BreadcrumbItem unchanged
class _BreadcrumbItem extends StatefulWidget {
  final String label;
  final String id;
  final String active;
  final Function(String) onTap;
  final double fontSize;

  const _BreadcrumbItem({
    required this.label,
    required this.id,
    required this.active,
    required this.onTap,
    this.fontSize = 16,
  });

  @override
  State<_BreadcrumbItem> createState() => _BreadcrumbItemState();
}

class _BreadcrumbItemState extends State<_BreadcrumbItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final bool isActive = widget.active == widget.id;
    final double paddingVertical = widget.fontSize < 16 ? 6 : 8;
    final double paddingHorizontal = widget.fontSize < 16 ? 4 : 6;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () => widget.onTap(widget.id),
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: paddingVertical,
            horizontal: paddingHorizontal,
          ),
          child: Text(
            widget.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: widget.fontSize,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              color: isActive
                  ? WebColors.success
                  : _isHovered
                      ? WebColors.success
                      : const Color(0xFF6B7280),
            ),
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
      padding: EdgeInsets.symmetric(
        horizontal: size < 20 ? 6 : 10,
      ),
      child: Icon(
        Icons.chevron_right,
        size: size,
        color: const Color(0xFF9CA3AF),
      ),
    );
  }
}