import 'package:flutter/material.dart';
import 'package:flutter_application_1/routes/navigation_utils.dart';
import 'package:flutter_application_1/routes/navigations/responsive_mobile_shell.dart';

class SuperAdminMobileShell extends StatelessWidget {
  final Widget child;

  const SuperAdminMobileShell({super.key, required this.child});

  void _onItemTapped(BuildContext context, int index) {
    goToPathByIndex(context, index, superAdminNavItems);
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveMobileShell(
      navItems: adminNavItems,
      primaryColor: Colors.yellow.shade200,
      selectedItemColor: Colors.yellow.shade700,
      onTapped: _onItemTapped,
      child: child,
    );
  }
}
