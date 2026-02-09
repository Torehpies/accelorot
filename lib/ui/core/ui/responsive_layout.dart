import 'package:flutter/material.dart';
import 'package:flutter_application_1/ui/core/themes/app_theme.dart';

/// Determines and displays the correct view based on screen width.
/// Supports mobile (<800), tablet (800-999), and desktop (>=1000) layouts.
class ResponsiveLayout extends StatelessWidget {
  final Widget mobileView;
  final Widget? tabletView;
  final Widget desktopView;

  const ResponsiveLayout({
    super.key,
    required this.mobileView,
    this.tabletView,
    required this.desktopView,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = MediaQuery.of(context).size.width;
        
        if (screenWidth >= kDesktopBreakpoint) {
          // Screens 1000+ get the desktop view
          return desktopView;
        } else if (screenWidth >= kTabletBreakpoint) {
          // Screens 800-999 get tablet view (or desktop if tablet not provided)
          return tabletView ?? desktopView;
        }
        // Screens <800 get the mobile view
        return mobileView;
      },
    );
  }
}
