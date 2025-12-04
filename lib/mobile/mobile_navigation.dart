// lib/mobile/navigation/mobile_navigation.dart

import 'package:flutter/material.dart';
import 'package:flutter_application_1/frontend/operator/activity_logs/activity_logs_screen.dart';
import 'package:flutter_application_1/ui/home_screen/view/home_screen.dart'
    show HomeScreen;
import 'package:flutter_application_1/frontend/operator/machine_management/operator_machine/operator_machine_screen.dart';
import 'package:flutter_application_1/frontend/operator/profile/profile_screen.dart';
import 'package:flutter_application_1/ui/mobile_statistics/statistics_screen.dart';

class MobileNavigation extends StatefulWidget {
  const MobileNavigation({super.key});

  @override
  State<MobileNavigation> createState() => _MobileNavigationState();
}

class _MobileNavigationState extends State<MobileNavigation> {
  int _selectedIndex = 0;

  // ✅ Use late final to avoid rebuilding list on every setState
  late final List<Widget> _screens = [
    const HomeScreen(),
    const ActivityLogsScreen(),
    const StatisticsScreen(),
    const OperatorMachineScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: const Color(
          0xFF1ABC9C,
        ), // 🟢 Teal green (matches your screenshot)
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {
              if (_selectedIndex != 4) {
                setState(() => _selectedIndex = 4);
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0), // ✅ Add padding for breathing room
        child: _screens[_selectedIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey[600],
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: "Activity"),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: "Stats"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: "Machines",
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add your FAB action here (e.g., add new machine, start batch)
        },
        backgroundColor: const Color(
          0xFF4CAF50,
        ), // 🟢 Green (matches your screenshot)
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
