import 'package:flutter/material.dart';
import 'package:flutter_application_1/routes/navigation_utils.dart';

class ResponsiveMobileShell extends StatelessWidget {
  final Widget child;
  final List<NavItem> navItems;
  final Color color;
  final Function(BuildContext, int) onTapped;
  final int? selectedIndex; // Optional: if set by StatefulShellRoute

  const ResponsiveMobileShell({
    super.key,
    required this.child,
    required this.navItems,
    required this.color,
    required this.onTapped,
    this.selectedIndex,
  });

  @override
  Widget build(BuildContext context) {
    final index = selectedIndex ?? getSelectedIndex(context, navItems);

    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: index,
        selectedItemColor: color,
        unselectedItemColor: Colors.grey,
        onTap: (i) => onTapped(context, i),
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
