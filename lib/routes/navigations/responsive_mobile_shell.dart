import 'package:flutter/material.dart';
import 'package:flutter_application_1/routes/navigation_utils.dart';
import 'package:go_router/go_router.dart';

class ResponsiveMobileShell extends StatelessWidget {
  final Widget child;
  final List<NavItem> navItems;
  final Color color;
  final Function(BuildContext, int) onTapped;

  const ResponsiveMobileShell({
    super.key,
    required this.child,
    required this.navItems,
    required this.color,
    required this.onTapped,
  });

  @override
  Widget build(BuildContext context) {
    final selectedIndex = getSelectedIndex(context, navItems);
    final String location = GoRouterState.of(context).uri.toString();
    final bool showFab = location != '/chat' && location != '/operator/qr-scan';
    // location != '/operator/dashboard';

    return Scaffold(
      //      appBar: AppBar(
      //        title: Text(navItems[selectedIndex].label),
      //        backgroundColor: primaryColor,
      //        foregroundColor: Colors.white,
      //      ),
      body: child,
      floatingActionButton: Visibility(
        visible: showFab,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 70.0),
          child: FloatingActionButton(
            onPressed: () {},
            elevation: 5,
            child: const Icon(Icons.smart_toy),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: selectedIndex,
        selectedItemColor: color,
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
