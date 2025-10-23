import 'package:flutter/material.dart';
import '../operator/dashboard/home_screen.dart';
import 'package:flutter_application_1/frontend/operator/activity_logs/widgets/activity_logs_navigator.dart';
import 'statistics_screen.dart';
import 'profile_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../operator/machine_management/machine_management_screen.dart';
import 'qr_refer.dart';
import 'package:flutter_application_1/services/auth_service.dart';


void logCurrentUser(BuildContext context) {
  final user = FirebaseAuth.instance.currentUser;

  // Remove any current snackbars and show a short message about auth state.
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

  const MainNavigation({
    super.key,
    this.showReferralOverlay = false,
    this.referralCode,
  });

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  // Add a GlobalKey to control the ActivityLogsNavigator
  final GlobalKey<NavigatorState> _activityNavigatorKey = GlobalKey<NavigatorState>();

  late final List<Widget> _screens = [
    const HomeScreen(),
    ActivityLogsNavigator(key: _activityNavigatorKey),
    const StatisticsScreen(),
    MachineManagementScreen(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;

    // 🔹 When switching tabs, reset ActivityLogsNavigator to its root
    if (_selectedIndex == 1) {
      _activityNavigatorKey.currentState?.popUntil((route) => route.isFirst);
    }

    setState(() {
      _selectedIndex = index;
    });
    // show the current auth info in a brief SnackBar
    logCurrentUser(context);
  }

  @override
  void initState() {
    super.initState();
    // Show initial auth info and optionally the referral overlay once after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      logCurrentUser(context);
      if (widget.showReferralOverlay) {
        _maybeShowReferralOverlay();
      }
    });
  }

  Future<void> _maybeShowReferralOverlay() async {
    try {
      final auth = AuthService();
      final user = auth.getCurrentUser();
      if (user == null) return;

      final hasShown = await auth.hasShownReferral(user.uid);
      if (hasShown) return;

      final code = widget.referralCode ?? user.uid.substring(0, 8).toUpperCase();

      if (!mounted) return;
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) {
          return Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.all(24),
            child: ReferralOverlay(
              referralCode: code,
              onSkip: () {
                Navigator.of(ctx).pop();
              },
            ),
          );
        },
      );

      await auth.markReferralShown(user.uid);
    } catch (e) {
      // ignore errors
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