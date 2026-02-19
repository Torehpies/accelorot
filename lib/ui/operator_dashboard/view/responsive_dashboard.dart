// lib/ui/operator_dashboard/view/responsive_dashboard.dart

import 'package:flutter/material.dart';
import 'package:flutter_application_1/ui/core/ui/responsive_layout.dart';
import 'operator_dashboard_view.dart';

class ResponsiveDashboard extends StatelessWidget {
  const ResponsiveDashboard({super.key});

  @override
  Widget build(BuildContext context) {

    return const ResponsiveLayout(
      mobileView: OperatorDashboardView(),
      desktopView: OperatorDashboardView(),
    );
  }
}
