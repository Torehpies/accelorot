// lib/ui/activity_logs/widgets/web_responsive_layout.dart

import 'package:flutter/material.dart';

/// Responsive layout wrapper that shows different layouts based on screen width
class WebResponsiveLayout extends StatelessWidget {
  final WidgetBuilder wide;    // >1200px
  final WidgetBuilder medium;  // 800-1200px
  final WidgetBuilder narrow;  // <800px

  const WebResponsiveLayout({
    super.key,
    required this.wide,
    required this.medium,
    required this.narrow,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 1200) {
          return wide(context);
        } else if (constraints.maxWidth > 800) {
          return medium(context);
        } else {
          return narrow(context);
        }
      },
    );
  }
}