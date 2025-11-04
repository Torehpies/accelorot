// lib/frontend/screens/main_navigation.dart

import 'package:flutter/material.dart';
import 'package:flutter_application_1/frontend/operator/statistics/statistics_screen.dart';
import 'dashboard/home_screen.dart';
import 'package:flutter_application_1/frontend/operator/activity_logs/widgets/activity_logs_navigator.dart';
import 'profile/profile_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'machine_management/operator_machine/operator_machine_screen.dart';
import 'machine_management/models/machine_model.dart';


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

class MainNavigation extends StatefulWidget {
  final bool showReferralOverlay;
  final String? referralCode;
  final MachineModel? focusedMachine;

  const MainNavigation({
    super.key,
    this.showReferralOverlay = false,
    this.referralCode,
    this.focusedMachine, 
  });

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  final GlobalKey<NavigatorState> _activityNavigatorKey = GlobalKey<NavigatorState>();

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    // ⭐ Initialize screens with focused machine if provided
    _screens = [
      HomeScreen(focusedMachine: widget.focusedMachine),
      ActivityLogsNavigator(
        key: _activityNavigatorKey,
        focusedMachineId: widget.focusedMachine?.machineId, // ⭐ Pass machine filter
      ),
      StatisticsScreen(
        focusedMachineId: widget.focusedMachine?.machineId,
        focusedMachine: widget.focusedMachine, // ⭐ Pass the full machine object
      ),
      const OperatorMachineScreen(),
      const ProfileScreen(),     
    ];
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;

    // Reset ActivityLogsNavigator when leaving the Activity tab
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
      // Show machine info in AppBar when in machine-focused mode
      appBar: widget.focusedMachine != null
          ? AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.focusedMachine!.machineName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Machine View • ID: ${widget.focusedMachine!.machineId}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
              elevation: 2,
            )
          : null,
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: widget.focusedMachine != null ? Colors.teal : Colors.blue,
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
    );
  }
}