import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../profile_screen.dart'; 
import '../../../operator/machine_management/machine_management_screen.dart';
import '../operator_management/operator_management_screen.dart';
import '../home_screen/admin_home_screen.dart';




class AdminMainNavigation extends StatefulWidget {
  const AdminMainNavigation({super.key});

  @override
  State<AdminMainNavigation> createState() => _AdminMainNavigationState();
}

class _AdminMainNavigationState extends State<AdminMainNavigation> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    AdminHomeScreen(),
    OperatorManagementScreen(), 
    MachineManagementScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        logCurrentUser(context);
      }
    });
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;

    setState(() {
      _selectedIndex = index;
    });

    logCurrentUser(context);
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.supervisor_account), label: "Operator"), 
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Machine"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}