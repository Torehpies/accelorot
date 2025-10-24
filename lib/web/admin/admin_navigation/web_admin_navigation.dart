// lib/web/admin/navigation/web_admin_main_navigation.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../frontend/screens/admin/operator_management/operator_management_screen.dart';
import '../../../frontend/operator/machine_management/admin_machine/admin_machine_screen.dart';
import '../screens/web_profile_screen.dart';
import '../screens/web_admin_home_screen.dart';

class WebAdminMainNavigation extends StatefulWidget {
  const WebAdminMainNavigation({super.key});

  @override
  State<WebAdminMainNavigation> createState() => _WebAdminMainNavigationState();
}

class _WebAdminMainNavigationState extends State<WebAdminMainNavigation> {
  int _selectedIndex = 0;

  final List<_NavItemData> _navItems = [
    _NavItemData(Icons.dashboard, 'Dashboard'),
    _NavItemData(Icons.supervisor_account, 'Operators'),
    _NavItemData(Icons.settings, 'Machines'),
    _NavItemData(Icons.person, 'Profile'),
  ];

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      const WebAdminHomeScreen(),
      const OperatorManagementScreen(),
      const AdminMachineScreen(),
      const WebProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar Navigation
          Container(
            width: 250,
            color: Colors.teal,
            child: Column(
              children: [
                const SizedBox(height: 32),
                // Logo
                const Text(
                  'Accel-O-Rot Admin',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  FirebaseAuth.instance.currentUser?.email ?? '',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
                const Divider(color: Colors.white30, height: 32),
                Expanded(
                  child: ListView.builder(
                    itemCount: _navItems.length,
                    itemBuilder: (context, index) {
                      final item = _navItems[index];
                      final isSelected = _selectedIndex == index;
                      return ListTile(
                        leading: Icon(item.icon, color: Colors.white),
                        title: Text(
                          item.label,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        selected: isSelected,
                        selectedTileColor: Colors.white.withOpacity(0.2),
                        onTap: () {
                          setState(() => _selectedIndex = index);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          // Main content
          Expanded(
            child: _screens[_selectedIndex],
          ),
        ],
      ),
    );
  }
}

class _NavItemData {
  final IconData icon;
  final String label;
  const _NavItemData(this.icon, this.label);
}