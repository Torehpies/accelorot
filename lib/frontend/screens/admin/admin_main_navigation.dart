import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'admin_home_screen.dart';
import 'user_management_screen.dart';
import '../profile_screen.dart'; // ✅ Adjust path if needed — this is your existing ProfileScreen
import '../../operator/machine_management/machine_management_screen.dart';

class AdminMainNavigation extends StatefulWidget {
  const AdminMainNavigation({super.key});

  @override
  State<AdminMainNavigation> createState() => _AdminMainNavigationState();
}

class _AdminMainNavigationState extends State<AdminMainNavigation> {
  int _selectedIndex = 0;

  // ✅ No 'const' — and use ProfileScreen (not AdminProfileScreen)
  final List<Widget> _screens = [
    AdminHomeScreen(),
    UserManagementScreen(),
    MachineManagementScreen(),
    ProfileScreen(), // ✅ Use your actual screen
  ];

  @override
  void initState() {
    super.initState();
    // Show initial auth info once after first frame
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

    // Show the current auth info in a brief SnackBar
    logCurrentUser(context);
  }

// Show brief auth-state SnackBar (mirrors MainNavigation behavior)
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
          BottomNavigationBarItem(icon: Icon(Icons.group), label: "Users"),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Machine"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}