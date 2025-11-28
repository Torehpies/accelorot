import 'package:flutter/material.dart';
import 'package:flutter_application_1/routes/navigation_utils.dart';
import 'package:flutter_application_1/routes/navigations/responsive_web_shell.dart';

class SuperAdminWebShell extends StatelessWidget {
  final Widget child;

  const SuperAdminWebShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ResponsiveWebShell(
      navItems: adminNavItems,
      primaryColor: Colors.yellow.shade700,
      secondaryColor: Colors.yellow.shade900,
      roleName: 'Super Admin',
      brandingWidget: buildAdminWebBranding(context),
      sidebarWidth: 250,
      child: child,
    );
  }
}
