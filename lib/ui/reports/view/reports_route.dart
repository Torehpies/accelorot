// lib/ui/reports/view/reports_route.dart

import 'package:flutter/material.dart';
import 'package:flutter_application_1/ui/core/ui/responsive_layout.dart';
import 'mobile_reports_view.dart';
import 'web_reports_view.dart';

class ReportsRoute extends StatelessWidget {
  const ReportsRoute({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobileView: const MobileReportsView(),
      desktopView: const WebReportsView(),
    );
  }
}