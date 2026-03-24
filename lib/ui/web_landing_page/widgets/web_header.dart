// lib/ui/core/widgets/web_header.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/constants/spacing.dart';
import '../../core/themes/web_colors.dart';
import '../buttons/header_button.dart';

class WebHeader extends StatefulWidget {
  final VoidCallback? onLogin;
  final VoidCallback? onGetStarted;
  final VoidCallback? onDownload;
  final Function(String)? onBreadcrumbTap;
  final String activeSection;
  final bool isScrolled;
  final bool showActions;

  const WebHeader({
    super.key,
    this.onLogin,
    this.onGetStarted,
    this.onDownload,
    this.onBreadcrumbTap,
    this.activeSection = 'home',
    this.isScrolled = true,
    this.showActions = true,
  });

  @override
  State<WebHeader> createState() => _WebHeaderState();
}

class _WebHeaderState extends State<WebHeader> {
  bool _isLogoHovered = false;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 768 && screenWidth < 1024;

    final horizontalPadding = isTablet ? AppSpacing.md : AppSpacing.xxl;
    const headerHeight = 72.0;
    final logoSize = isTablet ? 32.0 : 40.0;
    final appNameLogoWidth = isTablet ? 80.0 : 100.0;
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
                  blurRadius: 12,
                  spreadRadius: 0,
                  offset: const Offset(0, 3),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 6,
                  spreadRadius: 0,
                  offset: const Offset(0, 1),
                ),
              ]
            : [],
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        child: Row(
          children: [
            // ── Logo + Name ──────────────────────────────────────────────
            MouseRegion(
              cursor: SystemMouseCursors.click,
              onEnter: (_) => setState(() => _isLogoHovered = true),
              onExit: (_) => setState(() => _isLogoHovered = false),
              child: GestureDetector(
                onTap: () => widget.onBreadcrumbTap?.call('home'),
                child: AnimatedScale(
                  duration: const Duration(milliseconds: 200),
                  scale: _isLogoHovered ? 1.05 : 1.0,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SvgPicture.asset(
                        'assets/images/Accelorot_logo.svg',
                        width: logoSize,
                        height: logoSize,
                        fit: BoxFit.contain,
                      ),
                      if (showAppName) ...[
                        const SizedBox(width: AppSpacing.xs),
                        SvgPicture.asset(
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
                      ],
                    ],
                  ),
                ),
              ),
            ),

            // ── Breadcrumbs — shrinks via FittedBox, never scrolls ───────
            if (widget.onBreadcrumbTap != null) ...[
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _BreadcrumbItem(
                        label: 'Home',
                        id: 'home',
                        active: widget.activeSection,
                        onTap: widget.onBreadcrumbTap!,
                        fontSize: isTablet ? 13 : 14,
                      ),
                      _Chevron(size: isTablet ? 14 : 16),
                      _BreadcrumbItem(
                        label: 'Features',
                        id: 'features',
                        active: widget.activeSection,
                        onTap: widget.onBreadcrumbTap!,
                        fontSize: isTablet ? 13 : 14,
                      ),
                      _Chevron(size: isTablet ? 14 : 16),
                      _BreadcrumbItem(
                        label: 'How It Works',
                        id: 'how-it-works',
                        active: widget.activeSection,
                        onTap: widget.onBreadcrumbTap!,
                        fontSize: isTablet ? 13 : 14,
                      ),
                      _Chevron(size: isTablet ? 14 : 16),
                      _BreadcrumbItem(
                        label: 'Impact',
                        id: 'impact',
                        active: widget.activeSection,
                        onTap: widget.onBreadcrumbTap!,
                        fontSize: isTablet ? 13 : 14,
                      ),
                      _Chevron(size: isTablet ? 14 : 16),
                      _BreadcrumbItem(
                        label: 'Downloads',
                        id: 'download',
                        active: widget.activeSection,
                        onTap: widget.onBreadcrumbTap!,
                        fontSize: isTablet ? 13 : 14,
                      ),
                      _Chevron(size: isTablet ? 14 : 16),
                      _BreadcrumbItem(
                        label: 'FAQs',
                        id: 'faq',
                        active: widget.activeSection,
                        onTap: widget.onBreadcrumbTap!,
                        fontSize: isTablet ? 13 : 14,
                      ),
                      _Chevron(size: isTablet ? 14 : 16),
                      _BreadcrumbItem(
                        label: 'Contact',
                        id: 'contact',
                        active: widget.activeSection,
                        onTap: widget.onBreadcrumbTap!,
                        fontSize: isTablet ? 13 : 14,
                      ),
                      _Chevron(size: isTablet ? 14 : 16),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
            ],

            // ── Action Buttons ────────────────────────────────────────────
            if (widget.showActions &&
                widget.onLogin != null &&
                widget.onGetStarted != null)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  HeaderButton(
                    text: 'Login',
                    type: HeaderButtonType.outline,
                    onPressed: widget.onLogin!,
                    width: 85,
                    height: isTablet ? 32 : 36,
                    fontSize: isTablet ? 13 : 14,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  HeaderButton(
                    text: 'Get Started',
                    type: HeaderButtonType.filled,
                    onPressed: widget.onGetStarted!,
                    width: 120,
                    height: isTablet ? 32 : 36,
                    fontSize: isTablet ? 13 : 14,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

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
    this.fontSize = 14,
  });

  @override
  State<_BreadcrumbItem> createState() => _BreadcrumbItemState();
}

class _BreadcrumbItemState extends State<_BreadcrumbItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final bool isActive = widget.active == widget.id;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () => widget.onTap(widget.id),
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: widget.fontSize < 14 ? 4.0 : 6.0,
            horizontal: widget.fontSize < 14 ? 3.0 : 5.0,
          ),
          child: Text(
            widget.label,
            maxLines: 1,
            softWrap: false,
            style: TextStyle(
              fontSize: widget.fontSize,
              fontWeight:
                  isActive ? FontWeight.w600 : FontWeight.w500,
              color: isActive
                  ? const Color(0xFF22C55E)
                  : _isHovered
                      ? const Color(0xFF22C55E)
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

  const _Chevron({this.size = 14});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: size < 16 ? 3.0 : 5.0),
      child: Icon(
        Icons.chevron_right,
        size: size,
        color: const Color(0xFF9CA3AF),
      ),
    );
  }
}
