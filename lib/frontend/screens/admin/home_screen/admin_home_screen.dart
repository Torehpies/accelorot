import 'package:flutter/material.dart';
import 'widgets/stat_card.dart';
import 'operator_management/operator_management_section.dart';
import 'machine_management/machine_management_section.dart';
import 'models/admin_stats.dart';
import 'models/operator_model.dart';
import 'models/machine_model.dart';
import '../../../../services/admin_dashboard/mock_admin_data.dart';
import '../../../../services/admin_dashboard/admin_firestore_service.dart';
import '../../../../services/sess_service.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

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

  /// Load data based on authentication status
  /// - If logged in: fetch from Firestore
  /// - If not logged in: show mock data
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

  /// Load data from Firestore for logged-in admin
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

  /// Load mock data for non-logged-in users
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

  /// Handle "Manage >" tap for operators
  void _onOperatorManageTap() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Operator management coming soon'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  /// Handle "Manage >" tap for machines
  void _onMachineManageTap() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Machine management coming soon'),
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
      title: Text(
        _isLoggedIn ? 'Admin Dashboard' : 'Machine Name',
        style: const TextStyle(
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

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(
          child: StatCard(
            count: _stats.userCount,
            label: 'Operators',
            icon: Icons.person,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: StatCard(
            count: _stats.machineCount,
            label: 'Machines',
          ),
        ),
      ],
    );
  }
}