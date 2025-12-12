// lib/frontend/screens/admin/home_screen/admin_home_screen.dart
import 'package:flutter/material.dart';
import '../widgets/stat_card.dart';
import '../operator_management/operator_management_section.dart';
import '../machine_management/machine_management_section.dart';
import '../view_model/admin_stats.dart';
import '../view_model/operator_model.dart';
import '../view_model/machine_model.dart';
import '../../../data/services/local/mock_admin_data.dart';
import '../../../data/services/firebase/admin_firestore_service.dart';
import '../../../services/sess_service.dart';

/// Admin home screen with teal theme and auth-based data loading
class AdminHomeScreen extends StatefulWidget {
  final void Function(int index)? onNavigateToTab;

  const AdminHomeScreen({super.key, this.onNavigateToTab});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  final AdminFirestoreService _firestoreService = AdminFirestoreService();
  final SessionService _sessionService = SessionService();

  late AdminStats _stats;
  late List<OperatorModel> _operators;
  late List<MachineModel> _machines;
  bool _isLoading = true;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  /// Load data based on authentication status (mock vs Firestore)
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate network delay for smooth UX
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      // Check if user is logged in
      final user = _sessionService.currentUser;

      if (user != null) {
        // User is logged in - fetch real data from Firestore
        _isLoggedIn = true;
        await _loadFirestoreData(user.uid);
      } else {
        // User is NOT logged in - show mock data
        _isLoggedIn = false;
        _loadMockData();
      }
    } catch (e) {
      debugPrint('Error loading data: $e');
      // Fallback to mock data on error
      _loadMockData();
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Load data from Firestore for authenticated admin
  Future<void> _loadFirestoreData(String adminUid) async {
    try {
      // Admin's UID is their teamId
      final teamId = _firestoreService.getTeamId(adminUid);

      // Fetch stats, operators, and machines in parallel
      final results = await Future.wait([
        _firestoreService.fetchStats(teamId),
        _firestoreService.fetchOperatorsPreview(teamId),
        _firestoreService.fetchMachinesPreview(teamId),
      ]);

      _stats = results[0] as AdminStats;
      _operators = results[1] as List<OperatorModel>;
      _machines = results[2] as List<MachineModel>;
    } catch (e) {
      debugPrint('Firestore error: $e');
      // Fallback to mock data
      _loadMockData();
    }
  }

  /// Load mock data for non-authenticated users
  void _loadMockData() {
    _stats = MockAdminData.getStats();
    _operators = MockAdminData.getOperatorsPreview();
    _machines = MockAdminData.getMachinesPreview();
  }

  /// Handle notification icon tap
  void _onNotificationTap() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('No new notifications'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  /// Handle "Manage >" tap for operators - Navigate to Operator tab
  void _onOperatorManageTap() {
    if (widget.onNavigateToTab != null) {
      widget.onNavigateToTab!(1); // Navigate to Operator tab (index 1)
    } else {
      // Fallback if callback not provided
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Navigation not available'),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  /// Handle "Manage >" tap for machines - Navigate to Machine tab
  void _onMachineManageTap() {
    if (widget.onNavigateToTab != null) {
      widget.onNavigateToTab!(2); // Navigate to Machine tab (index 2)
    } else {
      // Fallback if callback not provided
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Navigation not available'),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: _buildAppBar(),
      body: _isLoading ? _buildLoadingState() : _buildContent(),
    );
  }

  /// Build teal app bar with bold black text
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.teal.shade600,
      automaticallyImplyLeading: false,
      title: Text(
        _isLoggedIn ? 'Admin Dashboard' : 'Machine Name',
        style: const TextStyle(
          color: Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: Colors.black),
          onPressed: _onNotificationTap,
        ),
      ],
    );
  }

  /// Build loading indicator
  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(color: Color(0xFF4CAF50)),
    );
  }

  /// Build main scrollable content with pull-to-refresh
  Widget _buildContent() {
    return RefreshIndicator(
      onRefresh: _loadData,
      color: const Color(0xFF4CAF50),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatsRow(),
              const SizedBox(height: 16),
              OperatorManagementSection(
                operators: _operators,
                onManageTap: _onOperatorManageTap,
              ),
              const SizedBox(height: 16),
              MachineManagementSection(
                machines: _machines,
                onManageTap: _onMachineManageTap,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  /// Build stats row with operator and machine counts (no icons)
  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(
          child: StatCard(count: _stats.userCount, label: 'Operators'),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: StatCard(count: _stats.machineCount, label: 'Machines'),
        ),
      ],
    );
  }
}
