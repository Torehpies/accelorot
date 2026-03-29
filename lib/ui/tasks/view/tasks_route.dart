// lib/ui/tasks/view/tasks_route.dart

import 'package:flutter/material.dart';
import 'package:flutter_application_1/ui/core/ui/responsive_layout.dart';
import 'mobile_tasks_view.dart';

class TasksRoute extends StatelessWidget {
  const TasksRoute({super.key});

  @override
  Widget build(BuildContext context) {
    return const ResponsiveLayout(
      mobileView: MobileTasksView(),
      desktopView: MobileTasksView(),
    );
  }
}
