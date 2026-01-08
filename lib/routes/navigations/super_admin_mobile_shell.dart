import 'package:flutter/material.dart';
import 'package:flutter_application_1/routes/navigation_utils.dart';
import 'package:flutter_application_1/routes/navigations/responsive_mobile_shell.dart';
import 'package:flutter_application_1/ui/core/themes/app_theme.dart';

class SuperAdminMobileShell extends StatelessWidget {
  final Widget child;

  const SuperAdminMobileShell({super.key, required this.child});

  void _onItemTapped(BuildContext context, int index) {
    goToPathByIndex(context, index, superAdminNavItems);
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveMobileShell(
      navItems: superAdminNavItems,
      color: AppColors.green100,
      onTapped: _onItemTapped,
      child: child,
    );
  }
}
