// lib/web/admin/screens/web_operator_view_nav.dart

import 'package:flutter/material.dart';
import '../../../frontend/operator/dashboard/home_screen.dart';
import '../../../frontend/operator/activity_logs/widgets/activity_logs_navigator.dart';
import '../../../frontend/operator/statistics/statistics_screen.dart';
import '../../../frontend/operator/machine_management/operator_machine/operator_machine_screen.dart';
import '../../../frontend/operator/profile/profile_screen.dart';

/// Web navigation screen for admins to view operator's dashboard
class WebOperatorViewNavigation extends StatefulWidget {
  final String operatorId;
  final String operatorName;

  const WebOperatorViewNavigation({
    super.key,
    required this.operatorId,
    required this.operatorName,
  });

  @override
  State<WebOperatorViewNavigation> createState() => _WebOperatorViewNavigationState();
}

class _WebOperatorViewNavigationState extends State<WebOperatorViewNavigation> {
  int _selectedIndex = 0;

  final GlobalKey<NavigatorState> _activityNavigatorKey = GlobalKey<NavigatorState>();

  late final List<Widget> _screens;

  static const List<_NavItem> _navItems = [
    _NavItem(Icons.home, 'Home'),
    _NavItem(Icons.history, 'Activity'),
    _NavItem(Icons.bar_chart, 'Statistics'),
    _NavItem(Icons.settings, 'Machines'),
    _NavItem(Icons.person, 'Profile'),
  ];

  @override
  void initState() {
    super.initState();
    // Pass operatorId to screens that need it
    _screens = [
      HomeScreen(viewingOperatorId: widget.operatorId),
      ActivityLogsNavigator(
        key: _activityNavigatorKey,
        viewingOperatorId: widget.operatorId,
      ),
      StatisticsScreen(viewingOperatorId: widget.operatorId),
      OperatorMachineScreen(viewingOperatorId: widget.operatorId),
      ProfileScreen(viewingOperatorId: widget.operatorId),
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
  }

  void _exitOperatorView() {
    // Show confirmation dialog before exiting
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit Operator View'),
        content: const Text('Return to admin dashboard?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Exit operator view
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
            child: const Text('Exit'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 250,
            color: Colors.teal,
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Operator View',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.operatorName,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
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
                          selectedTileColor: Colors.white.withValues(alpha: 0.1),
                          onTap: () => _onItemTapped(index),
                        );
                      },
                    ),
                  ),
                  const Divider(color: Colors.white30, height: 1),
                  ListTile(
                    leading: const Icon(Icons.arrow_back, color: Colors.white),
                    title: const Text(
                      'Back to Admin',
                      style: TextStyle(color: Colors.white),
                    ),
                    onTap: _exitOperatorView,
                  ),
                ],
              ),
            ),
          ),
          // Content Area
          Expanded(
            child: Scaffold(
              appBar: AppBar(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                elevation: 0,
                title: Text('${widget.operatorName} - ${_navItems[_selectedIndex].label}'),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.admin_panel_settings),
                    tooltip: 'Exit to Admin Dashboard',
                    onPressed: _exitOperatorView,
                  ),
                ],
              ),
              body: Padding(
                padding: const EdgeInsets.all(24),
                child: _screens[_selectedIndex],
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
