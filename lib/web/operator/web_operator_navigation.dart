import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/auth_wrapper.dart';
import '../../ui/web_operator_dashboard/view/web_home_screen.dart';
import '../../ui/web_statistics/web_statistics_screen.dart';
import '../../../ui/profile_screen/web_widgets/web_profile_view.dart';
import 'package:flutter_application_1/ui/activity_logs/view/web_activity_logs_main_nav.dart';
import '../../ui/web_operator_machine_management/view/machines_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WebOperatorNavigation extends StatefulWidget {
  const WebOperatorNavigation({super.key});

  @override
  State<WebOperatorNavigation> createState() => _WebOperatorNavigationState();
}

class _WebOperatorNavigationState extends State<WebOperatorNavigation> {
  int _selectedIndex = 0;
  String? _teamId;
  bool _isLoadingTeam = true;

  late List<Widget> _screens;

  final List<_NavItem> _navItems = const [
    _NavItem(Icons.dashboard, 'Dashboard'),
    _NavItem(Icons.history, 'Activity Logs'),
    _NavItem(Icons.bar_chart, 'Statistics'),
    _NavItem(Icons.settings, 'Machines'),
    _NavItem(Icons.person, 'Profile'),
  ];

  @override
  void initState() {
    super.initState();
    _loadTeamId();
  }

  Future<void> _loadTeamId() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        setState(() => _isLoadingTeam = false);
        return;
      }

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      final teamId = userDoc.data()?['teamId'] as String?;

      setState(() {
        _teamId = teamId;
        _isLoadingTeam = false;
        _screens = [
          WebHomeScreen(focusedMachine: null),
          const WebActivityLogsMainView(),
          const WebStatisticsScreen(),
          teamId != null
              ? MachinesView(teamId: teamId)
              : const _NoTeamWidget(),
          const WebProfileView(),
        ];
      });
    } catch (e) {
      debugPrint('Error loading teamId: $e');
      setState(() => _isLoadingTeam = false);
    }
  }

  Future<void> _handleLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (shouldLogout == true && mounted) {
      await FirebaseAuth.instance.signOut();
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const AuthWrapper()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingTeam) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
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
                  // Logo & Title
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.eco, size: 40, color: Colors.white),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Accel-O-Rot',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Operator Portal',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // User Info
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
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
                            FirebaseAuth.instance.currentUser?.email ?? 'User',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                            overflow: TextOverflow.ellipsis,
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
                                color: isSelected
                                    ? Colors.white
                                    : Colors.white70,
                                size: 22,
                              ),
                              title: Text(
                                item.label,
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.white70,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  fontSize: 14,
                                ),
                              ),
                              selected: isSelected,
                              selectedTileColor: Colors.white.withValues(
                                alpha: 0.15,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              onTap: () =>
                                  setState(() => _selectedIndex = index),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // Logout Button
                  Container(
                    margin: const EdgeInsets.all(16),
                    child: Material(
                      color: Colors.transparent,
                      child: ListTile(
                        leading: const Icon(
                          Icons.logout,
                          color: Colors.white70,
                          size: 22,
                        ),
                        title: const Text(
                          'Logout',
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(
                            color: Colors.white.withValues(alpha: 0.3),
                          ),
                        ),
                        onTap: _handleLogout,
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
              child: _screens[_selectedIndex],
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

// Widget to show when user has no team
class _NoTeamWidget extends StatelessWidget {
  const _NoTeamWidget();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.group_off,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No Team Assigned',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please contact your administrator',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}