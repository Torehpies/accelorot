import 'package:flutter/material.dart';
import 'package:flutter_application_1/routes/navigation_utils.dart';
import 'package:flutter_application_1/routes/navigations/responsive_web_shell.dart';

class WebShell extends StatelessWidget {
  final Widget child;

  const WebShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ResponsiveWebShell(
      navItems: operatorNavItems,
      primaryColor: Colors.teal.shade700,
      secondaryColor: Colors.teal.shade900,
      roleName: 'Operator',
      brandingWidget: buildOperatorWebBranding(context),
      sidebarWidth: 250,
      child: child,
    );
  }
}
