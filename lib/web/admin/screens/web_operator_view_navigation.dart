// lib/web/admin/screens/web_operator_view_navigation.dart

import 'package:flutter/material.dart';
import 'package:flutter_application_1/frontend/operator/dashboard/home_screen.dart';
import 'package:flutter_application_1/frontend/operator/activity_logs/widgets/activity_logs_navigator.dart';
import 'package:flutter_application_1/frontend/operator/statistics/statistics_screen.dart';
import 'package:flutter_application_1/frontend/operator/profile/profile_screen.dart';
import 'package:flutter_application_1/frontend/operator/machine_management/operator_machine/operator_machine_screen.dart';

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
  late final List<_NavItem> _navItems;

  @override
  void initState() {
    super.initState();
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

    _navItems = const [
      _NavItem(Icons.home, 'Home'),
      _NavItem(Icons.history, 'Activity'),
      _NavItem(Icons.bar_chart, 'Statistics'),
      _NavItem(Icons.settings, 'Machines'),
      _NavItem(Icons.person, 'Profile'),
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

  Future<void> _exitOperatorView() async {
    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit Operator View'),
        content: const Text('Return to admin dashboard?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
            child: const Text('Exit'),
          ),
        ],
      ),
    );

    if (shouldExit == true && mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _exitOperatorView();
        }
      },
      child: Scaffold(
        body: Row(
          children: [
            // Sidebar
            Container(
              width: 250,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.teal.shade700, Colors.teal.shade900],
                ),
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    // Operator View Badge
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                          width: 2,
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.visibility,
                                color: Colors.white,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Operator View',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.9),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 16,
                                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                                  child: const Icon(
                                    Icons.person,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    widget.operatorName,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(color: Colors.white30, height: 32),
                    
                    // Navigation Items
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        itemCount: _navItems.length,
                        itemBuilder: (context, index) {
                          final item = _navItems[index];
                          final isSelected = _selectedIndex == index;
                          return Container(
                            margin: const EdgeInsets.only(bottom: 4),
                            child: Material(
                              color: Colors.transparent,
                              child: ListTile(
                                leading: Icon(
                                  item.icon,
                                  color: isSelected ? Colors.white : Colors.white70,
                                  size: 22,
                                ),
                                title: Text(
                                  item.label,
                                  style: TextStyle(
                                    color: isSelected ? Colors.white : Colors.white70,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    fontSize: 14,
                                  ),
                                ),
                                selected: isSelected,
                                selectedTileColor: Colors.white.withValues(alpha: 0.15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                onTap: () => _onItemTapped(index),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    
                    // Exit Button
                    Container(
                      margin: const EdgeInsets.all(16),
                      child: Material(
                        color: Colors.transparent,
                        child: ListTile(
                          leading: const Icon(
                            Icons.exit_to_app,
                            color: Colors.white70,
                            size: 22,
                          ),
                          title: const Text(
                            'Exit to Admin',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(
                              color: Colors.white.withValues(alpha: 0.3),
                            ),
                          ),
                          onTap: _exitOperatorView,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Main Content Area
            Expanded(
              child: Container(
                color: Colors.grey[50],
                child: Column(
                  children: [
                    // Top Bar
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _navItems[_selectedIndex].label,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Viewing: ${widget.operatorName}',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.admin_panel_settings),
                            onPressed: _exitOperatorView,
                            tooltip: 'Exit to Admin Dashboard',
                            color: Colors.teal.shade700,
                          ),
                        ],
                      ),
                    ),
                    
                    // Screen Content
                    Expanded(
                      child: _screens[_selectedIndex],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem(this.icon, this.label);
}