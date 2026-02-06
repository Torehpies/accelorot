// lib/ui/core/widgets/app_header.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/constants/spacing.dart';
import '../../core/themes/web_colors.dart';

class AppHeader extends StatefulWidget {
  final VoidCallback? onHomeTap;
  final VoidCallback? onMenuTap;
  final bool isScrolled;

  const AppHeader({
    super.key,
    this.onHomeTap,
    this.onMenuTap,
    this.isScrolled = true,
  });

  @override
  State<AppHeader> createState() => _AppHeaderState();
}

class _AppHeaderState extends State<AppHeader> {
  bool _isLogoHovered = false;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isVerySmall = screenWidth < 320;

    final horizontalPadding = isVerySmall
        ? AppSpacing.sm
        : AppSpacing.md;

    final headerHeight = 64.0;
    final logoSize = isVerySmall ? 32.0 : 40.0;
    final appNameLogoWidth = isVerySmall ? 80.0 : 100.0;
    final showAppName = screenWidth > 280;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      height: headerHeight,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
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
            // Logo + Name SVG section
            Flexible(
              flex: 1,
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                onEnter: (_) => setState(() => _isLogoHovered = true),
                onExit: (_) => setState(() => _isLogoHovered = false),
                child: GestureDetector(
                  onTap: widget.onHomeTap,
                  child: AnimatedScale(
                    duration: const Duration(milliseconds: 200),
                    scale: _isLogoHovered ? 1.05 : 1.0,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          child: SvgPicture.asset(
                            'assets/images/Accelorot_logo.svg',
                            width: logoSize,
                            height: logoSize,
                            fit: BoxFit.contain,
                          ),
                        ),
                        if (showAppName) ...[
                          const SizedBox(width: AppSpacing.xs),
                          Flexible(
                            child: SvgPicture.asset(
                              'assets/images/Accelorot_name.svg',
                              width: appNameLogoWidth,
                              height: logoSize,
                              fit: BoxFit.contain,
                              colorFilter: ColorFilter.mode(
                                _isLogoHovered
                                    ? const Color(0xFF22C55E)
                                    : WebColors.buttonsPrimary,
                                BlendMode.srcIn,
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
            
            // Hamburger menu icon
            if (widget.onMenuTap != null)
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
          ],
        ),
      ),
    );
  }
}