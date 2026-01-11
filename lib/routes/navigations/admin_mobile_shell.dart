import 'package:flutter/material.dart';
import 'package:flutter_application_1/routes/navigation_utils.dart';
import 'package:flutter_application_1/routes/navigations/responsive_mobile_shell.dart';
import 'package:flutter_application_1/ui/core/themes/app_theme.dart';

class AdminMobileShell extends StatelessWidget {
  final Widget child;

  const AdminMobileShell({super.key, required this.child});

  void _onItemTapped(BuildContext context, int index) {
    goToPathByIndex(context, index, adminNavItems);
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveMobileShell(
      navItems: adminNavItems,
      color: AppColors.green100,
      onTapped: _onItemTapped,
      child: child,
    );
  }
}
