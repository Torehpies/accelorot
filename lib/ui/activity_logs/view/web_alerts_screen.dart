// lib/ui/activity_logs/view/web_alerts_screen.dart

import 'package:flutter/material.dart';
import '../view_model/activity_viewmodel.dart';
import '../widgets/web_activity_list_view.dart';

/// Full alerts list screen
class WebAlertsScreen extends StatelessWidget {
  final String? focusedMachineId;

  const WebAlertsScreen({
    super.key,
    this.focusedMachineId,
  });

  @override
  Widget build(BuildContext context) {
    final params = ActivityParams(
      screenType: ActivityScreenType.alerts,
      focusedMachineId: focusedMachineId,
    );

    return WebActivityListView(
      params: params,
      itemsPerPage: 10,
    );
  }
}