import 'package:flutter/material.dart';
import 'package:flutter_application_1/routes/navigation_utils.dart';
import 'package:flutter_application_1/routes/responsive_mobile_shell.dart';

class MobileNavigationShell extends StatelessWidget {
  final Widget child;

  const MobileNavigationShell({super.key, required this.child});

  void _onItemTapped(BuildContext context, int index) {
    goToPathByIndex(context, index, operatorNavItems);
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveMobileShell(
      navItems: operatorNavItems,
      primaryColor: Colors.teal.shade700,
      selectedItemColor: Colors.teal,
      onTapped: _onItemTapped,
      child: child,
    );
  }
}
