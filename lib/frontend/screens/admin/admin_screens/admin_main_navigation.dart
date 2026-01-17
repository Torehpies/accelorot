import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../ui/profile_screen/widgets/profile_view.dart';
import '../../../../ui/machine_management/view/admin_machine_view.dart'; 
import '../operator_management/operator_management_screen.dart';
import '../../../../ui/admin_dashboard/view/mobile_admin_home_view.dart';
import '../../../../ui/reports/view/mobile_reports_view.dart';

class AdminMainNavigation extends StatefulWidget {
  const AdminMainNavigation({super.key});

  @override
  State<AdminMainNavigation> createState() => _AdminMainNavigationState();
}

class _AdminMainNavigationState extends State<AdminMainNavigation> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        logCurrentUser(context);
      }
    });
  }

  List<Widget> _buildScreens() {
    return [
      MobileAdminHomeView(),
      const OperatorManagementScreen(teamId: '',),
      const AdminMachineView(), 
      const MobileReportsView(),
      const ProfileView(),
    ];
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
    final screens = _buildScreens();

    return Scaffold(
      body: screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: "Home"),
          BottomNavigationBarItem(
            icon: Icon(Icons.supervisor_account),
            label: "Operator",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Machine"),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: "Reports"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}