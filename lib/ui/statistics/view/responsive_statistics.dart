import 'package:flutter/material.dart';
import 'package:flutter_application_1/ui/core/ui/responsive_layout.dart';
import 'statistics_screen.dart';
import 'web_statistics_screen.dart';

class ResponsiveStatistics extends StatelessWidget {
  final String? focusedMachineId;

  const ResponsiveStatistics({super.key, this.focusedMachineId});

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobileView: StatisticsScreen(focusedMachineId: focusedMachineId),
      desktopView: WebStatisticsScreen(focusedMachineId: focusedMachineId),
    );
  }
}
