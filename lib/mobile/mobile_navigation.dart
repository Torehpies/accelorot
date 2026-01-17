// lib/mobile/navigation/mobile_navigation.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/sess_service.dart';
import '../../ui/activity_logs/view/activity_logs_navigator.dart';
import '../../ui/operator_dashboard/view/home_screen.dart';
import '../../ui/machine_management/view/operator_machine_view.dart';
import '../../ui/profile_screen/widgets/profile_view.dart';
import '../../ui/mobile_statistics/statistics_screen.dart';

class MobileNavigation extends ConsumerStatefulWidget {
  const MobileNavigation({super.key});

  @override
  ConsumerState<MobileNavigation> createState() => _MobileNavigationState();
}

class _MobileNavigationState extends ConsumerState<MobileNavigation> {
  int _selectedIndex = 0;
  String? _teamId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTeamId();
  }

  Future<void> _loadTeamId() async {
    try {
      final sessionService = SessionService();
      final userData = await sessionService.getCurrentUserData();
      final teamId = userData?['teamId'] as String?;
      if (mounted) {
        setState(() {
          _teamId = teamId;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        // Optionally show snackbar or error
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // If teamId is missing, you could show an error — but assume it exists
    final screens = [
      const HomeScreen(),
      const ActivityLogsNavigator(focusedMachineId: null),
      const StatisticsScreen(),
      OperatorMachineView(teamId: _teamId ?? ''), // ⚠️ Fallback, but better to guard
      const ProfileView(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: const Color(0xFF1ABC9C),
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
        padding: const EdgeInsets.all(16.0),
        child: _teamId == null
            ? const Center(child: Text('No team assigned.'))
            : screens[_selectedIndex],
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
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Machines"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add your FAB action here
        },
        backgroundColor: const Color(0xFF4CAF50),
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}