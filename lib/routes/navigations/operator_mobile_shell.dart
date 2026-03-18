import 'package:flutter/material.dart';
import 'package:flutter_application_1/routes/navigation_utils.dart';
import 'package:flutter_application_1/routes/navigations/responsive_mobile_shell.dart';
import 'package:flutter_application_1/ui/core/themes/app_theme.dart';
import 'package:go_router/go_router.dart';

class MobileNavigationShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MobileNavigationShell({super.key, required this.navigationShell});

  void _onItemTapped(BuildContext context, int index) {
    // goBranch keeps each tab's widget tree alive
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveMobileShell(
      navItems: operatorNavItems,
      color: AppColors.green100,
      selectedIndex: navigationShell.currentIndex,
      onTapped: _onItemTapped,
      child: navigationShell,
    );
  }
}
