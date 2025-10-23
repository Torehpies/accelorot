import 'package:flutter/material.dart';
import 'components/stat_card.dart';
import 'components/user_management_section.dart';
import 'models/admin_user_model.dart';
import '../../../../services/admin_data/mock_admin_data.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  late AdminStats _stats;
  late List<AdminUserModel> _section1Users;
  late List<AdminUserModel> _section2Users;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // Load data (mock for now, replace with Firestore later)
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    if (mounted) {
      setState(() {
        _stats = MockAdminData.getStats();
        _section1Users = MockAdminData.getUsersForSection(0);
        _section2Users = MockAdminData.getUsersForSection(1);
        _isLoading = false;
      });
    }
  }

  // Handle stat card taps
  void _onUserStatTap() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('User statistics tapped'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _onMachineStatTap() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Machine statistics tapped'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  // Handle manage button taps
  void _onManageSection1() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Manage Section 1 users'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _onManageSection2() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Manage Section 2 users'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  // Handle user card taps
  void _onUserTap(AdminUserModel user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(user.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Email: ${user.email}'),
            const SizedBox(height: 8),
            Text('Role: ${user.role}'),
            const SizedBox(height: 8),
            Text('ID: ${user.id}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  // Handle notification icon tap
  void _onNotificationTap() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('No new notifications'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: _buildAppBar(),
      body: _isLoading ? _buildLoadingState() : _buildContent(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF1B5E20),
      automaticallyImplyLeading: false,
      title: const Text(
        'Machine Name',
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: Colors.white),
          onPressed: _onNotificationTap,
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(
        color: Color(0xFF4CAF50),
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatsRow(),
            const SizedBox(height: 16),
            UserManagementSection(
              title: 'User Management',
              users: _section1Users,
              onManageTap: _onManageSection1,
              onUserTap: _onUserTap,
            ),
            const SizedBox(height: 16),
            UserManagementSection(
              title: 'User Management',
              users: _section2Users,
              onManageTap: _onManageSection2,
              onUserTap: _onUserTap,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(
          child: StatCard(
            count: _stats.userCount,
            label: 'User',
            icon: Icons.person,
            onTap: _onUserStatTap,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: StatCard(
            count: _stats.machineCount,
            label: 'Machines',
            onTap: _onMachineStatTap,
          ),
        ),
      ],
    );
  }
}