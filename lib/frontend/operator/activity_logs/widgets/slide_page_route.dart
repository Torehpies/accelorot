// lib/frontend/operator/activity_logs/widgets/slide_page_route.dart
import 'package:flutter/material.dart';

/// Reusable page route with slide (right->left) + slight fade.
class SlidePageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  final RouteSettings? routeSettings;

  SlidePageRoute({required this.page, this.routeSettings})
      : super(
          settings: routeSettings,
          transitionDuration: const Duration(milliseconds: 300),
          reverseTransitionDuration: const Duration(milliseconds: 300),
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
  const begin = Offset(1.0, 0.0);
  const end = Offset.zero;
  final slideTween = Tween(begin: begin, end: end)
      .chain(CurveTween(curve: Curves.easeOutCubic));

  return SlideTransition(
    position: animation.drive(slideTween),
    child: child,
  );
},

        );
}
