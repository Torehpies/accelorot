import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ScaffoldWithNavbar extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const ScaffoldWithNavbar({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: navigationShell.currentIndex,
        onTap: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: "Dashboard",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: "Activity"),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: "Statistics",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: "Users"),
          BottomNavigationBarItem(
            icon: Icon(Icons.engineering),
            label: "Machines",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}
