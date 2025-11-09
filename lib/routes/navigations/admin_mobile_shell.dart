import 'package:flutter/material.dart';
import 'package:flutter_application_1/routes/navigation_utils.dart';
import 'package:flutter_application_1/routes/navigations/responsive_mobile_shell.dart';

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
      primaryColor: Colors.red.shade700,
      selectedItemColor: Colors.red.shade700,
      onTapped: _onItemTapped,
      child: child,
    );
  }
}
