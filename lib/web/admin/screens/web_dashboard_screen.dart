// lib/web/admin/screens/web_dashboard_screen.dart

// ignore_for_file: non_constant_identifier_names
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/frontend/operator/activity_logs/widgets/activity_logs_navigator.dart';
import 'package:flutter_application_1/frontend/operator/profile/profile_screen.dart';
import 'package:flutter_application_1/frontend/operator/statistics/statistics_screen.dart';
import 'package:flutter_application_1/mobile/mobile_navigation.dart' show MachineManagementScreen;
import 'package:flutter_application_1/web/navigation/web_navigation_layout.dart';
import 'package:flutter_application_1/web/navigation/nav_item.dart';

// ✅ Import new components
import 'package:flutter_application_1/web/components/metric_card.dart';
import 'package:flutter_application_1/web/components/sensor_card.dart';
import 'package:flutter_application_1/web/components/system_card.dart';
// ignore: unused_import
import 'package:flutter_application_1/web/components/composting_card.dart' hide SystemCard;
import 'package:flutter_application_1/web/components/dashboard_floating_action_button.dart';

class WebDashboardScreen extends StatefulWidget {
  const WebDashboardScreen({super.key});

  @override
  State<WebDashboardScreen> createState() => _WebDashboardScreenState();
}

class _WebDashboardScreenState extends State<WebDashboardScreen> {
  int _selectedIndex = 0;

  // ✅ Keep the activity logs navigator key for nested navigation
  final _activityNavigatorKey = GlobalKey<NavigatorState>();

  // ✅ Make _screens non-final so it can be initialized in initState
  late final List<Widget> _screens;

  // ✅ Navigation items definition
  static const List<NavItem> _navItems = [
    NavItem(Icons.dashboard, 'Dashboard'),
    NavItem(Icons.history, 'Activity Logs'),
    NavItem(Icons.bar_chart, 'Statistics'),
    NavItem(Icons.settings, 'Machines'),
    NavItem(Icons.people, 'Users'),
    NavItem(Icons.person, 'Profile'),
    NavItem(Icons.logout, 'Logout'),
  ];

  // ✅ Initialize screens with proper components
  @override
  void initState() {
    super.initState();
    _screens = [
      const _DashboardContent(),
      ActivityLogsNavigator(key: _activityNavigatorKey),
      const StatisticsScreen(),
      const MachineManagementScreen(),
      const _UsersPlaceholder(),
      const ProfileScreen(),
    ];
  }

  // ✅ Handle navigation with special logic for Activity Logs and Logout
  void _handleNavigation(int index) {
    // Handle logout separately
    if (index == _navItems.length - 1) {
      _handleLogout();
      return;
    }

    // Don't navigate if already selected
    if (index == _selectedIndex) return;

    // Pop Activity Logs stack when leaving
    if (_selectedIndex == 1) {
      _activityNavigatorKey.currentState?.popUntil((route) => route.isFirst);
    }

    setState(() {
      _selectedIndex = index;
    });
  }

  void _handleLogout() {
    FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return WebNavigationLayout(
      selectedIndex: _selectedIndex,
      screens: _screens,
      navItems: _navItems,
      onItemSelected: _handleNavigation,
    );
  }
}

// 🎯 EXACTLY MATCHING REFERENCE UI
class _DashboardContent extends StatelessWidget {
  const _DashboardContent();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          height: constraints.maxHeight,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔢 Top Metrics Row (3 cards)
              SizedBox(
                height: 90,
                child: Row(
                  children: [
                    Expanded(
                      child: MetricCard(
                        title: 'Total Machines',
                        value: '10',
                        icon: Icons.devices,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: MetricCard(
                        title: 'Total Admins',
                        value: '10',
                        icon: Icons.person,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: MetricCard(
                        title: 'Total Users',
                        value: '10',
                        icon: Icons.people,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 🌿 Environmental Sensors Section
              const Text(
                '🌿 Environmental Sensors',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 100,
                child: Row(
                  children: [
                    Expanded(
                      child: SensorCard(
                        label: 'Temperature',
                        value: '3°',
                        valueColor: Colors.green,
                        time: '1.2 hrs ago',
                        icon: Icons.thermostat,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SensorCard(
                        label: 'Moisture',
                        value: '3%',
                        valueColor: Colors.orange,
                        time: '1.5 hrs ago',
                        icon: Icons.water_drop,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SensorCard(
                        label: 'Oxygen Level',
                        value: '3',
                        valueColor: Colors.red,
                        time: '2 hrs ago',
                        icon: Icons.air,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ⚙️ System Section
              const Text(
                '⚙️ System',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 120,
                child: SystemCard(
                  title: 'Drum Rotation',
                  lastRotated: 'Last Rotated: 12:00 PM, Aug 10, 2024',
                  onRotate: () {},
                ),
              ),
              const SizedBox(height: 20),

              // 🔄 Composting Progress Section
              const Text(
                '🔄 Composting Progress',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 80,
                child: CompostingCard(
                  progress: 0.4,
                  startDate: 'Aug 01, 2024',
                  endDate: 'Sept 01, 2024',
                  daysLeft: '3 days left',
                ),
              ),

              // ➕ Floating Action Button (bottom right)
              Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: DashboardFloatingActionButton(
                    onPressed: () {
                      // Modal will go here later
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ignore: body_might_complete_normally_nullable
Widget? CompostingCard({required double progress, required String startDate, required String endDate, required String daysLeft}) {
}

// 👥 Users Placeholder
class _UsersPlaceholder extends StatelessWidget {
  const _UsersPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Users Management',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'User management coming soon',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}