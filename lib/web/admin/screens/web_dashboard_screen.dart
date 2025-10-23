// lib/web/screens/web_dashboard_screen.dart

import 'package:flutter/material.dart';
import '../../../frontend/operator/dashboard/home_screen.dart';
import '../../../frontend/operator/activity_logs/widgets/activity_logs_navigator.dart';
import 'web_statistics_screen.dart';
import 'web_profile_screen.dart';
import 'package:flutter_application_1/frontend/operator/machine_management/admin_machine/admin_machine_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

void logCurrentUser(BuildContext context) {
  final user = FirebaseAuth.instance.currentUser;

  ScaffoldMessenger.of(context).removeCurrentSnackBar();

  if (user != null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Logged-in: ${user.email} (UID: ${user.uid})'),
        duration: const Duration(seconds: 2),
      ),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('No user is currently logged in.'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}

class WebDashboardScreen extends StatefulWidget {
  const WebDashboardScreen({super.key});

  @override
  State<WebDashboardScreen> createState() => _WebDashboardScreenState();
}

class _WebDashboardScreenState extends State<WebDashboardScreen> {
  int _selectedIndex = 0;
  late List<Widget> _screens;
  final GlobalKey<NavigatorState> _activityNavigatorKey = GlobalKey<NavigatorState>();

  final List<_NavItemData> _navData = [
    _NavItemData(Icons.home, 'Home'),
    _NavItemData(Icons.history, 'Activity'),
    _NavItemData(Icons.bar_chart, 'Stats'),
    _NavItemData(Icons.settings, 'Machines'),
    _NavItemData(Icons.person, 'Profile'),
  ];

  @override
  void initState() {
    super.initState();
    _screens = [
      const HomeScreen(),
      ActivityLogsNavigator(key: _activityNavigatorKey),
      const WebStatisticsScreen(),
      const AdminMachineScreen(),
      WebProfileScreen(),
    ];
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;

    if (_selectedIndex == 1) {
      _activityNavigatorKey.currentState?.popUntil((route) => route.isFirst);
    }

    setState(() {
      _selectedIndex = index;
    });

    logCurrentUser(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Operator Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () => _onItemTapped(4),
          ),
        ],
      ),
      body: Row(
        children: [
          NavigationRail(
            groupAlignment: -1,
            labelType: null,
            selectedIndex: _selectedIndex,
            onDestinationSelected: _onItemTapped,
            extended: true,
            destinations: _buildNavigationDestinations(),
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(child: _screens[_selectedIndex]),
        ],
      ),
    );
  }

  List<NavigationRailDestination> _buildNavigationDestinations() {
    return _navData.map((data) {
      return NavigationRailDestination(
        icon: Icon(data.icon),
        selectedIcon: Icon(data.icon),
        label: Text(data.label),
      );
    }).toList(growable: false);
  }
}

class _NavItemData {
  final IconData icon;
  final String label;
  const _NavItemData(this.icon, this.label);
}