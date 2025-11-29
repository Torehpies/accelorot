// lib/ui/activity_logs/activity_logs_navigator.dart

import 'package:flutter/material.dart';
import 'activity_logs_main_view.dart';
import 'package:flutter_application_1/frontend/operator/activity_logs/view_screens/all_activity_screen.dart';
import 'package:flutter_application_1/frontend/operator/activity_logs/view_screens/substrates_screen.dart';
import 'package:flutter_application_1/frontend/operator/activity_logs/view_screens/alerts_screen.dart';
import 'package:flutter_application_1/frontend/operator/activity_logs/view_screens/cycles_recom_screen.dart';
import 'package:flutter_application_1/frontend/operator/activity_logs/view_screens/reports_screen.dart';

/// Main navigator for Activity Logs tab with nested routing
class ActivityLogsNavigator extends StatelessWidget {
  final String? focusedMachineId;

  const ActivityLogsNavigator({super.key, this.focusedMachineId});

  @override
  Widget build(BuildContext context) {
    return Navigator(
      onGenerateRoute: (settings) {
        // Route handler - passes focusedMachineId to all screens
        Widget page;

        switch (settings.name) {
          case '/':
            // Overview page - now uses refactored ActivityLogsScreen
            page = ActivityLogsScreen(focusedMachineId: focusedMachineId);
            break;

          case '/all-activity':
            page = AllActivityScreen(focusedMachineId: focusedMachineId);
            break;

          case '/substrates':
            final args = settings.arguments as Map<String, dynamic>?;
            page = SubstratesScreen(
              focusedMachineId: focusedMachineId,
              initialFilter: args?['initialFilter'],
            );
            break;

          case '/alerts':
            final args = settings.arguments as Map<String, dynamic>?;
            page = AlertsScreen(
              focusedMachineId: focusedMachineId,
              initialFilter: args?['initialFilter'],
            );
            break;

          case '/cycles-recom':
            final args = settings.arguments as Map<String, dynamic>?;
            page = CyclesRecomScreen(
              focusedMachineId: focusedMachineId,
              initialFilter: args?['initialFilter'],
            );
            break;

          case '/reports':
            final args = settings.arguments as Map<String, dynamic>?;
            page = ReportsScreen(
              focusedMachineId: focusedMachineId,
              initialFilter: args?['initialFilter'],
            );
            break;

          default:
            page = ActivityLogsScreen(focusedMachineId: focusedMachineId);
        }

        // Apply slide animation to all routes except home
        if (settings.name == '/') {
          return MaterialPageRoute(builder: (context) => page);
        }

        return _SlidePageRoute(builder: (context) => page);
      },
    );
  }
}

/// Custom page route with slide transition animation
class _SlidePageRoute extends PageRouteBuilder {
  final WidgetBuilder builder;

  _SlidePageRoute({required this.builder})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) =>
              builder(context),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeInOut;
            var tween = Tween(begin: begin, end: end)
                .chain(CurveTween(curve: curve));
            var offsetAnimation = animation.drive(tween);
            return SlideTransition(position: offsetAnimation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 300),
        );
}