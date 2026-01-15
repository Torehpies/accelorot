// lib/ui/activity_logs/view/activity_logs_route.dart
import 'package:flutter/material.dart';
import 'activity_logs_navigator.dart';
import 'unified_activity_view.dart';

class ActivityLogsRoute extends StatelessWidget {
  const ActivityLogsRoute({super.key});

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        final width = MediaQuery.sizeOf(context).width;
        
        if (width >= 900) {
          return const UnifiedActivityView();
        }
        return const ActivityLogsNavigator();
      },
    );
  }
}