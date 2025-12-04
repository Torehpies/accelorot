// lib/ui/activity_logs/view/web_cycles_screen.dart

import 'package:flutter/material.dart';
import '../view_model/activity_viewmodel.dart';
import '../widgets/web_activity_list_view.dart';

/// Full cycles list screen
class WebCyclesScreen extends StatelessWidget {
  final String? focusedMachineId;

  const WebCyclesScreen({
    super.key,
    this.focusedMachineId,
  });

  @override
  Widget build(BuildContext context) {
    final params = ActivityParams(
      screenType: ActivityScreenType.cyclesRecom,
      focusedMachineId: focusedMachineId,
    );

    return WebActivityListView(
      params: params,
      itemsPerPage: 10,
    );
  }
}