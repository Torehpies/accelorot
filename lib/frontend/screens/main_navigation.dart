import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'package:flutter_application_1/frontend/operator/activity_logs/widgets/activity_logs_navigator.dart';
import 'statistics_screen.dart';
import 'profile_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  // 🔹 Add a GlobalKey to control the ActivityLogsNavigator
  final GlobalKey<NavigatorState> _activityNavigatorKey = GlobalKey<NavigatorState>();

  late final List<Widget> _screens = [
    const HomeScreen(),
    ActivityLogsNavigator(key: _activityNavigatorKey),
    const StatisticsScreen(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;

    // 🔹 When switching tabs, reset ActivityLogsNavigator to its root
    if (_selectedIndex == 1) {
      _activityNavigatorKey.currentState?.popUntil((route) => route.isFirst);
    }

    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: "Activity"),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: "Stats"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}
