// lib/web/operator/web_operator_navigation.dart

// ignore_for_file: deprecated_member_use

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/frontend/operator/activity_logs/activity_logs_screen.dart';
import 'package:flutter_application_1/frontend/operator/dashboard/home_screen.dart';
import 'package:flutter_application_1/frontend/operator/profile/profile_screen.dart';
import 'package:flutter_application_1/frontend/operator/statistics/statistics_screen.dart';
import 'package:flutter_application_1/mobile/mobile_navigation.dart' show MachineManagementScreen;
// Import the web-specific screens if they exist
// import 'package:flutter_application_1/web/operator/web_home_screen.dart';

class WebOperatorNavigation extends StatefulWidget {
  const WebOperatorNavigation({super.key});

  @override
  State<WebOperatorNavigation> createState() => _WebOperatorNavigationState();
}

class _WebOperatorNavigationState extends State<WebOperatorNavigation> {
  int _selectedIndex = 0;

  // ✅ Define screens - matching the nav items
  late final List<Widget> _screens = [
    const HomeScreen(),              // 0 - Dashboard
    const ActivityLogsScreen(),      // 1 - Activity Logs
    const StatisticsScreen(),        // 2 - Statistics
    const MachineManagementScreen(), // 3 - Machines
    const ProfileScreen(),           // 4 - Users (placeholder, needs proper screen)
    const ProfileScreen(),           // 5 - Profile
  ];

  static const List<_NavItem> _navItems = [
    _NavItem(Icons.dashboard, 'Dashboard'),      // Index 0
    _NavItem(Icons.history, 'Activity Logs'),    // Index 1
    _NavItem(Icons.bar_chart, 'Statistics'),     // Index 2
    _NavItem(Icons.settings, 'Machines'),        // Index 3
    _NavItem(Icons.people, 'Users'),             // Index 4
    _NavItem(Icons.person, 'Profile'),           // Index 5
    _NavItem(Icons.logout, 'Logout'),            // Index 6 (special)
  ];

  void _handleNavigation(int index) async {
    // Handle logout separately
    if (index == _navItems.length - 1) {
      await _handleLogout();
      return;
    }

    // Update selected index for regular navigation
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _handleLogout() async {
    try {
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        // Navigate to login screen
        Navigator.of(context).pushReplacementNamed('/login'); // Adjust route
      }
    } catch (e) {
      ('Logout error: $e');
    }
  }

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
                  // Header
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
                  
                  // Navigation Items
                  Expanded(
                    child: ListView.builder(
                      itemCount: _navItems.length,
                      itemBuilder: (context, index) {
                        final item = _navItems[index];
                        final isLogout = index == _navItems.length - 1;
                        final isSelected = _selectedIndex == index && !isLogout;

                        return ListTile(
                          leading: Icon(
                            item.icon,
                            color: Colors.white,
                          ),
                          title: Text(
                            item.label,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: Colors.white,
                          selectedTileColor: Colors.white.withOpacity(0.2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
                          onTap: () => _handleNavigation(index),
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
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                elevation: 1,
                title: Text(
                  _navItems[_selectedIndex].label,
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined),
                    onPressed: () {
                      // Handle notifications
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.account_circle),
                    onPressed: () => setState(() => _selectedIndex = 5), // Profile
                  ),
                  const SizedBox(width: 8),
                ],
              ),
              body: Container(
                color: Colors.grey[50],
                child: Padding(
                  padding: const EdgeInsets.all(24),
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