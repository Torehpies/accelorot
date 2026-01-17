// lib/ui/activity_logs/view/activity_logs_route.dart
import 'package:flutter/material.dart';
import 'package:flutter_application_1/ui/core/ui/responsive_layout.dart';
import 'package:flutter_application_1/ui/machine_management/view/web_operator_machine_screen.dart';

class ActivityLogsRoute extends StatelessWidget {
  const ActivityLogsRoute({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobileView: const WebOperatorMachineScreen(),
      desktopView: const WebOperatorMachineScreen(),
    );
  }
}