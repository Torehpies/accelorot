// lib/frontend/screens/admin/operator_management/operator_view_navigation.dart
import 'package:flutter/material.dart';
import '../../../operator/dashboard/home_screen.dart';
import 'package:flutter_application_1/frontend/operator/activity_logs/widgets/activity_logs_navigator.dart';
import '../../../operator/statistics/statistics_screen.dart';
import '../../profile_screen.dart';
import '../../../operator/machine_management/machine_management_screen.dart';

/// Navigation screen for admins to view operator's dashboard
class OperatorViewNavigation extends StatefulWidget {
  final String operatorId;
  final String operatorName;

  const OperatorViewNavigation({
    super.key,
    required this.operatorId,
    required this.operatorName,
  });

  @override
  State<OperatorViewNavigation> createState() => _OperatorViewNavigationState();
}

class _OperatorViewNavigationState extends State<OperatorViewNavigation> {
  int _selectedIndex = 0;

  final GlobalKey<NavigatorState> _activityNavigatorKey = GlobalKey<NavigatorState>();

  late final List<Widget> _screens;

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
      MachineManagementScreen(viewingOperatorId: widget.operatorId),
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
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _exitOperatorView();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.teal,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Operator View',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
              ),
              Text(
                widget.operatorName,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _exitOperatorView,
            tooltip: 'Back to Admin',
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.admin_panel_settings),
              onPressed: _exitOperatorView,
              tooltip: 'Exit to Admin Dashboard',
            ),
          ],
        ),
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
            BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Machines"),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
          ],
        ),
      ),
    );
  }
}