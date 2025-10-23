// lib/web/navigation/web_navigation.dart

// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_application_1/frontend/operator/activity_logs/activity_logs_screen.dart';
import 'package:flutter_application_1/frontend/operator/dashboard/home_screen.dart';
import 'package:flutter_application_1/frontend/operator/machine_management/machine_management_screen.dart';
import 'package:flutter_application_1/frontend/operator/profile/profile_screen.dart';
import 'package:flutter_application_1/frontend/operator/statistics/statistics_screen.dart';
// ignore: unused_import
import 'package:flutter_application_1/frontend/screens/statistics_screen.dart';

class WebNavigation extends StatefulWidget {
  const WebNavigation({super.key});

  @override
  State<WebNavigation> createState() => _WebNavigationState();
}

class _WebNavigationState extends State<WebNavigation> {
  int _selectedIndex = 0;

  late final List<Widget> _screens = [
    const HomeScreen(),
    const ActivityLogsScreen(),
    const StatisticsScreen(),
    const MachineManagementScreen(),
    const ProfileScreen(),
  ];

  static const List<_NavItem> _navItems = [
    _NavItem(Icons.dashboard, 'Dashboard'),
    _NavItem(Icons.history, 'Activity Logs'),
    _NavItem(Icons.bar_chart, 'Statistics'),
    _NavItem(Icons.settings, 'Machines'),
    _NavItem(Icons.people, 'Users'),
    _NavItem(Icons.person, 'Profile'),
    _NavItem(Icons.logout, 'Logout'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // 🟢 Green Sidebar
          Container(
            width: 250,
            color: const Color(0xFF1ABC9C), // Teal green
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Accel-O-Rot',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Divider(color: Colors.white30, height: 1),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _navItems.length,
                      itemBuilder: (context, index) {
                        final item = _navItems[index];
                        return ListTile(
                          leading: Icon(item.icon, color: Colors.white),
                          title: Text(
                            item.label,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: _selectedIndex == index ? FontWeight.bold : null,
                            ),
                          ),
                          selected: _selectedIndex == index,
                          selectedColor: Colors.white,
                          selectedTileColor: Colors.white.withOpacity(0.1),
                          hoverColor: Colors.green.withOpacity(0.05), // 👈 Add this
                          onTap: () {
                            if (index == _navItems.length - 1) {
                              // Logout action
                              ('Logout clicked');
                            } else {
                              setState(() => _selectedIndex = index);
                            }
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          // White Content Area
          Expanded(
            child: Scaffold(
              appBar: AppBar(
                title: const Text('Operator Dashboard'),
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                elevation: 0,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.account_circle),
                    onPressed: () => setState(() => _selectedIndex = 5),
                  ),
                ],
              ),
              body: Padding(
                padding: const EdgeInsets.all(24),
                child: SingleChildScrollView(
                  child: _screens[_selectedIndex],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem(this.icon, this.label);
}