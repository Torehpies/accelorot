import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/themes/web_text_styles.dart';
import '../../core/themes/web_colors.dart';
import '../../core/ui/primary_button.dart';
import '../../core/ui/header_button.dart'; 
import 'package:flutter_svg/flutter_svg.dart';



class AppSpacing {
  static const double xs = 8.0;
  static const double sm = 12.0;
  static const double md = 16.0;
  static const double xl = 24.0;
  static const double lg = 20.0;
  static const double xxxl = 48.0;
}

class DownloadApp extends StatelessWidget {
  const DownloadApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              'assets/images/bg.png',
              fit: BoxFit.cover,
              cacheHeight: 1000,
              cacheWidth: 1000,
              colorBlendMode: BlendMode.modulate,
            ),
          ),
          // Content with responsive padding
          SafeArea(
            child: Column(
              children: [
                // App Header
                _AppHeader(
                  onBreadcrumbTap: (section) {
                    context.go('/');
                  },
                  activeSection: 'download',
                  isScrolled: true,
                ),

                // Main content area
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final isMobile = constraints.maxWidth < 900;
                      final maxWidth = isMobile ? double.infinity : 1200.0;
                      final horizontalPadding = isMobile ? AppSpacing.lg : AppSpacing.xxxl;

                      Widget content = isMobile 
                        ? Column(
                            children: [
                              // Mobile: Text content first
                              Container(
                                constraints: BoxConstraints(maxWidth: maxWidth),
                                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    RichText(
                                      textAlign: TextAlign.center,
                                      text: const TextSpan(
                                        style: TextStyle(
                                          fontFamily: 'dm-sans',
                                          fontSize: 32,
                                          fontWeight: FontWeight.w800,
                                          height: 1.2,
                                          color: Colors.white,
                                        ),
                                        children: [
                                          TextSpan(text: 'Download the\n'),
                                          TextSpan(
                                            text: 'Accel-O-Rot App',
                                            style: TextStyle(
                                              color: Color(0xFF22C55E),
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: AppSpacing.lg),
                                    Text(
                                      'Get our AI-powered mobile app to monitor your composting system, '
                                      'receive real-time insights, and manage your organic waste efficiently.\n\n'
                                      'Available for Android.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 14,
                                        height: 1.6,
                                        color: Colors.white.withValues(alpha: 0.9),
                                      ),
                                    ),
                                    const SizedBox(height: AppSpacing.xxxl),
                                    ConstrainedBox(
                                      constraints: const BoxConstraints(maxWidth: 280),
                                      child: SizedBox(
                                        width: MediaQuery.of(context).size.width * 0.85,
                                        height: 56,
                                        child: PrimaryButton(
                                          text: 'Download APK v1.0.0',
                                          onPressed: () {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(
                                                content: Text('Downloading Accel-O-Rot v1.0.0.apk'),
                                                backgroundColor: Color(0xFF22C55E),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: AppSpacing.xxxl),
                                  ],
                                ),
                              ),
                              _PhonePreview(),
                            ],
                          )
                        : Padding(
                            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Desktop: Phone preview on LEFT
                                Expanded(
                                  flex: 1,
                                  child: Center(child: _PhonePreview()),
                                ),
                                const SizedBox(width: AppSpacing.xxxl),
                                // Desktop: Text content on RIGHT
                                Expanded(
                                  flex: 1,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      RichText(
                                        textAlign: TextAlign.start,
                                        text: const TextSpan(
                                          style: TextStyle(
                                            fontFamily: 'dm-sans',
                                            fontSize: 44,
                                            fontWeight: FontWeight.w800,
                                            height: 1.2,
                                            color: Colors.white,
                                          ),
                                          children: [
                                            TextSpan(text: 'Download the\n'),
                                            TextSpan(
                                              text: 'Accel-O-Rot App',
                                              style: TextStyle(
                                                color: Color(0xFF22C55E),
                                                fontWeight: FontWeight.w800,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: AppSpacing.lg),
                                      Text(
                                        'Get our AI-powered mobile app to monitor your composting system, '
                                        'receive real-time insights, and manage your organic waste efficiently.\n\n'
                                        'Available for Android.',
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                          fontSize: 16,
                                          height: 1.6,
                                          color: Colors.white.withValues(alpha: 0.9),
                                        ),
                                      ),
                                      const SizedBox(height: AppSpacing.xxxl),
                                      ConstrainedBox(
                                        constraints: const BoxConstraints(maxWidth: 280),
                                        child: SizedBox(
                                          width: 260,
                                          height: 56,
                                          child: PrimaryButton(
                                            text: 'Download APK v1.0.0',
                                            onPressed: () {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(
                                                  content: Text('Downloading Accel-O-Rot v1.0.0.apk'),
                                                  backgroundColor: Color(0xFF22C55E),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );

                      // Apply scrolling only on mobile
                      if (isMobile) {
                        content = SingleChildScrollView(
                          child: content,
                        );
                      }

                      return content;
                    },
                  ),
                ),
              ],
            ),
          ),
          
          // Image courtesy credit - bottom right
          Positioned(
            bottom: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Image courtesy of A1 Organics',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Phone preview and helper widgets
class _PhonePreview extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      height: 570,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            blurRadius: 50,
            offset: const Offset(0, 20),
            color: Colors.black.withValues(alpha: 0.15),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('9:41', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
              Row(
                children: [
                  Icon(Icons.signal_cellular_alt, size: 14),
                  SizedBox(width: 3),
                  Icon(Icons.wifi, size: 14),
                  SizedBox(width: 3),
                  Icon(Icons.battery_full, size: 14),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          Expanded(
            child: ScrollConfiguration(
              behavior: ScrollBehavior().copyWith(scrollbars: false),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            title: 'Total Operators',
                            value: '15',
                            percentage: '13%',
                            icon: Icons.person_outline,
                            color: const Color(0xFF22C55E),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _StatCard(
                            title: 'Total Machines',
                            value: '12',
                            percentage: '8%',
                            icon: Icons.settings_outlined,
                            color: const Color(0xFF3B82F6),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Analytics',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.grey.shade300),
                                  ),
                                  child: const Text(
                                    'Activity',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'Reports',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Activity Overview',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Row(
                                children: [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF22C55E),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Text(
                                    'Per Day',
                                    style: TextStyle(
                                      fontSize: 9,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            height: 90,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: const [
                                _ChartBar(height: 0, label: 'Thu'),
                                _ChartBar(height: 0, label: 'Fri'),
                                _ChartBar(height: 0, label: 'Sat'),
                                _ChartBar(height: 70, label: 'Sun'),
                                _ChartBar(height: 0, label: 'Mon'),
                                _ChartBar(height: 0, label: 'Tue'),
                                _ChartBar(height: 0, label: 'Wed'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Recent Activities',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Icon(Icons.refresh, size: 16, color: Colors.grey.shade600),
                            ],
                          ),
                          const SizedBox(height: 10),
                          const _ActivityItem(
                            icon: Icons.air,
                            iconColor: Color(0xFF3B82F6),
                            title: 'Aerator',
                            subtitle: 'machine01',
                            category: 'Aerator',
                            status: 'COMPLETE',
                          ),
                          const SizedBox(height: 10),
                          const _ActivityItem(
                            icon: Icons.settings_input_component,
                            iconColor: Color(0xFF3B82F6),
                            title: 'Drum Controller',
                            subtitle: 'machine01',
                            category: 'Drum',
                            status: 'COMPLETE',
                          ),
                          const SizedBox(height: 10),
                          const _ActivityItem(
                            icon: Icons.settings_input_component,
                            iconColor: Color(0xFF3B82F6),
                            title: 'Drum Controller',
                            subtitle: 'machine01',
                            category: 'Drum',
                            status: 'COMPLETE',
                          ),
                          const SizedBox(height: 10),
                          const _ActivityItem(
                            icon: Icons.air,
                            iconColor: Color(0xFF3B82F6),
                            title: 'Aerator',
                            subtitle: 'machine01',
                            category: 'Drum',
                            status: 'COMPLETE',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String percentage;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.percentage,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 9,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 3),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Icon(icon, size: 10, color: color),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '$percentage compared this month',
            style: TextStyle(
              fontSize: 7,
              color: Colors.grey.shade500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _ChartBar extends StatelessWidget {
  final double height;
  final String label;

  const _ChartBar({
    required this.height,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 16,
          height: height,
          decoration: BoxDecoration(
            color: height > 0 ? const Color(0xFF22C55E) : Colors.transparent,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: TextStyle(
            fontSize: 7,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String category;
  final String status;

  const _ActivityItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.category,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(7),
          ),
          child: Icon(icon, size: 14, color: iconColor),
        ),
        const SizedBox(width: 7),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 1),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 8,
                  color: Colors.grey.shade600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(width: 7),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              category,
              style: TextStyle(
                fontSize: 8,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 1),
            Text(
              status,
              style: TextStyle(
                fontSize: 7,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// App Header Widget - UPDATED WITH HEADERBUTTON
class _AppHeader extends StatefulWidget {
  final Function(String) onBreadcrumbTap;
  final String activeSection;
  final bool isScrolled;

  const _AppHeader({
    required this.onBreadcrumbTap,
    required this.activeSection,
    required this.isScrolled,
  });

  @override
  State<_AppHeader> createState() => _AppHeaderState();
}

class _AppHeaderState extends State<_AppHeader> {
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
                  IconButton(
                    icon: Icon(
                      Icons.menu,
                      color: WebColors.textPrimary,
                      size: isVerySmall ? 24 : 28,
                    ),
                    onPressed: () {
                      // Handle menu tap
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    tooltip: 'Open menu',
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  SizedBox(
                    width: isVerySmall ? 90 : 110,
                    height: 32,
                    child: PrimaryButton(
                      text: isVerySmall ? 'Start' : 'Get Started',
                      onPressed: () {
                        context.go('/');
                      },
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
                  // ✅ NOW USING HeaderButton INSTEAD OF TextButton
                  SizedBox(
                    width: 100,
                    height: isTablet ? 38 : 42,
                    child: HeaderButton(
                      text: 'Login',
                      onPressed: () {},
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  SizedBox(
                    width: 140,
                    height: isTablet ? 38 : 42,
                    child: PrimaryButton(
                      text: 'Get Started',
                      onPressed: () {
                        context.go('/');
                      },
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

// Keep _BreadcrumbItem unchanged with hover functionality
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