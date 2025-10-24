// lib/web/admin/screens/web_dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_application_1/frontend/operator/activity_logs/activity_logs_screen.dart';
// ignore: unused_import
import 'package:flutter_application_1/frontend/operator/dashboard/home_screen.dart';
import 'package:flutter_application_1/frontend/operator/profile/profile_screen.dart';
import 'package:flutter_application_1/frontend/operator/statistics/statistics_screen.dart';
import 'package:flutter_application_1/mobile/mobile_navigation.dart' show MachineManagementScreen;
import 'package:flutter_application_1/web/navigation/web_navigation_layout.dart';
import 'package:flutter_application_1/web/navigation/nav_item.dart';

class WebDashboardScreen extends StatefulWidget {
  const WebDashboardScreen({super.key});

  @override
  State<WebDashboardScreen> createState() => _WebDashboardScreenState();
}

class _WebDashboardScreenState extends State<WebDashboardScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const _DashboardContent(), // 👈 This is your photo UI
    const ActivityLogsScreen(),
    const StatisticsScreen(),
    const MachineManagementScreen(),
    const _UsersPlaceholder(),
    const ProfileScreen(),
  ];

  static const List<NavItem> _navItems = [
    NavItem(Icons.dashboard, 'Dashboard'),
    NavItem(Icons.history, 'Activity Logs'),
    NavItem(Icons.bar_chart, 'Statistics'),
    NavItem(Icons.settings, 'Machines'),
    NavItem(Icons.people, 'Users'),
    NavItem(Icons.person, 'Profile'),
    NavItem(Icons.logout, 'Logout'),
  ];

  void _onNavigationItemSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WebNavigationLayout(
      selectedIndex: _selectedIndex,
      screens: _screens,
      navItems: _navItems,
      onItemSelected: _onNavigationItemSelected,
    );
  }
}

// 🎯 THIS IS YOUR PHOTO UI — FULLY RECREATED
class _DashboardContent extends StatelessWidget {
  const _DashboardContent();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔢 Metrics Row (3 cards)
          Row(
            children: [
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Total Machines', style: Theme.of(context).textTheme.bodyMedium),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text('10', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                            const Spacer(),
                            Icon(Icons.devices, color: Colors.grey[400]),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Total Admins', style: Theme.of(context).textTheme.bodyMedium),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text('10', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                            const Spacer(),
                            Icon(Icons.person, color: Colors.grey[400]),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Total Users', style: Theme.of(context).textTheme.bodyMedium),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text('10', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                            const Spacer(),
                            Icon(Icons.people, color: Colors.grey[400]),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // 🌿 Environmental Sensors Section
          const Text(
            'Environmental Sensors',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Temperature', style: Theme.of(context).textTheme.bodyMedium),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text('3°', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green)),
                            const Spacer(),
                            Text('1.2 hrs ago', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Moisture', style: Theme.of(context).textTheme.bodyMedium),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text('3%', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.orange)),
                            const Spacer(),
                            Text('1.5 hrs ago', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Oxygen Level', style: Theme.of(context).textTheme.bodyMedium),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text('3', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.red)),
                            const Spacer(),
                            Text('2 hrs ago', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // ⚙️ System Status Section
          const Text(
            'System',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Drum Rotation',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text('Last Rotated: 12:00 PM, Aug 10, 2024'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Rotate'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // 🔄 Composting Progress Section
          const Text(
            'Composting Progress',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Decomposition'),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: 0.4, // 40%
                    backgroundColor: Colors.grey[200],
                    color: Colors.yellow,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Start: Aug 01, 2024 — In Progress'),
                      const Text('End: Sept 01, 2024 — 3 days left'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // ➕ Floating Action Button (bottom right)
          Align(
            alignment: Alignment.bottomRight,
            child: FloatingActionButton(
              onPressed: () {
               
              },
              backgroundColor: Colors.green,
              child: const Icon(Icons.add),
            ),
          ),
        ],
      ),
    );
  }
}

class _UsersPlaceholder extends StatelessWidget {
  const _UsersPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Users Management',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.people, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                const Text('User management coming soon'),
              ],
            ),
          ),
        ),
      ],
    );
  }
}