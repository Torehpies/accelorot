import 'package:flutter/material.dart';
import 'package:flutter_application_1/routes/navigation_utils.dart';
import 'package:flutter_application_1/routes/responsive_web_shell.dart';

class AdminWebShell extends StatelessWidget {
  final Widget child;

  const AdminWebShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ResponsiveWebShell(
      navItems: operatorNavItems,
      primaryColor: Colors.red.shade700,
      secondaryColor: Colors.red.shade900,
      roleName: 'Admin',
      brandingWidget: buildOperatorWebBranding(context),
      sidebarWidth: 250,
      child: child,
    );
  }
}
