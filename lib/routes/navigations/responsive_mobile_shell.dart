import 'package:flutter/material.dart';
import 'package:flutter_application_1/routes/navigation_utils.dart';

class ResponsiveMobileShell extends StatelessWidget {
  final Widget child;
  final List<NavItem> navItems;
  final Color primaryColor;
  final Color selectedItemColor;
  final Function(BuildContext, int) onTapped;

  const ResponsiveMobileShell({
    super.key,
    required this.child,
    required this.navItems,
    required this.primaryColor,
    required this.selectedItemColor,
    required this.onTapped,
  });

  @override
  Widget build(BuildContext context) {
    final selectedIndex = getSelectedIndex(context, navItems);

    return Scaffold(
//      appBar: AppBar(
//        title: Text(navItems[selectedIndex].label),
//        backgroundColor: primaryColor,
//        foregroundColor: Colors.white,
//      ),
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: selectedIndex,
        selectedItemColor: selectedItemColor,
        unselectedItemColor: Colors.grey,
        onTap: (index) => onTapped(context, index),
        items: navItems.map((item) {
          return BottomNavigationBarItem(
            icon: Icon(item.icon),
            label: item.label,
          );
        }).toList(),
      ),
    );
  }
}
