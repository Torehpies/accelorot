import 'package:flutter/material.dart';
import 'package:flutter_application_1/ui/core/ui/responsive_layout.dart';
import 'mobile_admin_home_view.dart';
import 'web_admin_home_view.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return const ResponsiveLayout(
      mobileView: MobileAdminHomeView(),
      desktopView: WebAdminHomeView(),
    );
  }
}