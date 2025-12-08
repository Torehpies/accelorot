import 'package:flutter/material.dart';

const int kDesktopBreakpoint = 800;

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
        if (constraints.maxWidth >= kDesktopBreakpoint) {
          // Screens wider than 800 get the desktop view
          return desktopView;
        }
        // Screens 800 or less get the mobile view
        return mobileView;
      },
    );
  }
}

