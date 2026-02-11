// lib/ui/core/widgets/web_header.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/constants/spacing.dart';
import '../../core/themes/web_colors.dart';
import '../../core/ui/primary_button.dart';
import '../../web_landing_page/buttons/button_one.dart';

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

    final horizontalPadding = isTablet
        ? AppSpacing.lg
        : AppSpacing.xxxl;

    final headerHeight = 88.0;
    final logoSize = isTablet ? 40.0 : 50.0;
    final appNameLogoWidth = isTablet ? 100.0 : 130.0;
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
            // Logo + Name SVG section with hover effect
            Flexible(
              flex: 1,
              child: MouseRegion(
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
            
            // Breadcrumbs navigation
            if (widget.onBreadcrumbTap != null)
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
                        onTap: widget.onBreadcrumbTap!,
                        fontSize: isTablet ? 15 : 16,
                      ),
                      _Chevron(size: isTablet ? 18 : 20),
                      _BreadcrumbItem(
                        label: 'Features',
                        id: 'features',
                        active: widget.activeSection,
                        onTap: widget.onBreadcrumbTap!,
                        fontSize: isTablet ? 15 : 16,
                      ),
                      _Chevron(size: isTablet ? 18 : 20),
                      _BreadcrumbItem(
                        label: 'How It Works',
                        id: 'how-it-works',
                        active: widget.activeSection,
                        onTap: widget.onBreadcrumbTap!,
                        fontSize: isTablet ? 15 : 16,
                      ),
                      _Chevron(size: isTablet ? 18 : 20),
                      _BreadcrumbItem(
                        label: 'Impact',
                        id: 'impact',
                        active: widget.activeSection,
                        onTap: widget.onBreadcrumbTap!,
                        fontSize: isTablet ? 15 : 16,
                      ),
                      _Chevron(size: isTablet ? 18 : 20),
                      _BreadcrumbItem(
                        label: 'Downloads',
                        id: 'download',
                        active: widget.activeSection,
                        onTap: widget.onBreadcrumbTap!,
                        fontSize: isTablet ? 15 : 16,
                      ),
                      _Chevron(size: isTablet ? 18 : 20),
                      _BreadcrumbItem(
                        label: 'FAQs',
                        id: 'faq',
                        active: widget.activeSection,
                        onTap: widget.onBreadcrumbTap!,
                        fontSize: isTablet ? 15 : 16,
                      ),
                      _Chevron(size: isTablet ? 18 : 20),
                      _BreadcrumbItem(
                        label: 'Contact',
                        id: 'contact',
                        active: widget.activeSection,
                        onTap: widget.onBreadcrumbTap!,
                        fontSize: isTablet ? 15 : 16,
                      ),
                    ],
                  ),
                ),
              ),
            
            // Login and Get Started buttons
            if (widget.showActions && widget.onLogin != null && widget.onGetStarted != null)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 100,
                    height: isTablet ? 38 : 42,
                    child: ButtonOne(
                      text: 'Login',
                      onPressed: widget.onLogin!,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  SizedBox(
                    width: 140,
                    height: isTablet ? 38 : 42,
                    child: PrimaryButton(
                      text: 'Get Started',
                      onPressed: widget.onGetStarted!,
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
            overflow: TextOverflow.visible,
            softWrap: false,
            style: TextStyle(
              fontSize: widget.fontSize,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
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