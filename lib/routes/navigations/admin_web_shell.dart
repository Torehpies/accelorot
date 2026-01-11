import 'package:flutter/material.dart';
import 'package:flutter_application_1/routes/navigation_utils.dart';
import 'package:flutter_application_1/routes/navigations/responsive_web_shell.dart';
import 'package:flutter_application_1/ui/core/themes/app_theme.dart';
import 'package:flutter_application_1/ui/core/ui/web_branding.dart';

class AdminWebShell extends StatelessWidget {
  final Widget child;

  const AdminWebShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ResponsiveWebShell(
      navItems: adminNavItems,
      // primaryColor: Colors.red.shade700,
      // secondaryColor: Colors.red.shade900,
			color: AppColors.background,
      roleName: 'Admin',
      brandingWidget: WebBranding(),
      sidebarWidth: 250,
      child: child,
    );
  }
}
