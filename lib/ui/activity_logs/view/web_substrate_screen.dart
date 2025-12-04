// lib/ui/activity_logs/view/web_substrate_screen.dart

import 'package:flutter/material.dart';
import '../view_model/activity_viewmodel.dart';
import '../widgets/web_activity_list_view.dart';

/// Full substrate list screen
class WebSubstrateScreen extends StatelessWidget {
  final String? viewingOperatorId;
  final String? focusedMachineId;

  const WebSubstrateScreen({
    super.key,
    this.viewingOperatorId,
    this.focusedMachineId,
  });

  @override
  Widget build(BuildContext context) {
    final params = ActivityParams(
      screenType: ActivityScreenType.substrates,
      viewingOperatorId: viewingOperatorId,
      focusedMachineId: focusedMachineId,
    );

    return WebActivityListView(
      params: params,
      itemsPerPage: 10,
    );
  }
}