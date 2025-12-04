// lib/ui/activity_logs/view/web_reports_screen.dart

import 'package:flutter/material.dart';
import '../view_model/activity_viewmodel.dart';
import '../widgets/web_activity_list_view.dart';

/// Full reports list screen
class WebReportsScreen extends StatelessWidget {
  final String? viewingOperatorId;
  final String? focusedMachineId;

  const WebReportsScreen({
    super.key,
    this.viewingOperatorId,
    this.focusedMachineId,
  });

  @override
  Widget build(BuildContext context) {
    final params = ActivityParams(
      screenType: ActivityScreenType.reports,
      viewingOperatorId: viewingOperatorId,
      focusedMachineId: focusedMachineId,
    );

    return WebActivityListView(
      params: params,
      itemsPerPage: 10,
    );
  }
}