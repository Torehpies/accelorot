import 'package:flutter/material.dart';
import 'package:flutter_application_1/ui/core/themes/app_theme.dart';

/// Determines and displays the correct view based on screen width.
class ResponsiveLayout extends StatelessWidget {
  final Widget mobileView;
  final Widget desktopView;

  const ResponsiveLayout({
    super.key,
    required this.mobileView,
    required this.desktopView,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop =
            MediaQuery.of(context).size.width >= kDesktopBreakpoint;
        if (isDesktop) {
          // Screens wider than 800 get the desktop view
          return desktopView;
        }
        // Screens 800 or less get the mobile view
        return mobileView;
      },
    );
  }
}
