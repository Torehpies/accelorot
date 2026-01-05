// lib/ui/web_admin_home/view_model/web_admin_dashboard_view_model.dart
import 'package:flutter/material.dart';
//import 'package:firebase_auth/firebase_auth.dart';
//import '../../../../data/repositories/machine_repository/machine_repository.dart';
//import '../../../../data/repositories/machine_repository/machine_repository.dart';
import '../../../../data/models/operator_model.dart';
import '../../../../data/models/machine_model.dart';

class WebAdminDashboardViewModel extends ChangeNotifier {
  final dynamic repository;
  final String teamId;

  bool _loading = false;
  bool get loading => _loading;

  List<OperatorModel> _operators = [];
  List<MachineModel> _machines = [];

  // Cache data to prevent re-fetching
  bool _hasLoaded = false;
  DateTime? _lastLoadTime;

  WebAdminDashboardViewModel(this.repository, this.teamId);

  // Make this method smarter - don't reload if recently loaded
  Future<void> loadStats() async {
    // Don't reload if we just loaded recently (within 30 seconds)
    if (_hasLoaded && 
        _lastLoadTime != null && 
        DateTime.now().difference(_lastLoadTime!) < const Duration(seconds: 30)) {
      return;
    }

    _loading = true;
    notifyListeners();

    try {
      _operators = await repository.getOperators(teamId);
      _machines = await repository.getMachinesByTeam(teamId);
      
      _hasLoaded = true;
      _lastLoadTime = DateTime.now();
    } catch (e) {
      debugPrint('Dashboard error: $e');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // Getters that return cached data
  int get totalOperators => _operators.length;
  int get totalMachines => _machines.length;
  int get totalReports => 125;

  double get operatorGrowthRate => _calculateGrowthRate(_operators.length);
  double get machineGrowthRate => _calculateGrowthRate(_machines.length);
  double get reportGrowthRate => 8.5;

  List<Map<String, dynamic>> get activities => _generateActivities();
  Map<String, int> get reportStatus => _generateReportStatus();
  List<Map<String, dynamic>> get recentActivities => _generateRecentActivities();
  List<Map<String, dynamic>> get recentActivitiesTable => _generateRecentActivitiesTable();

  // Helper methods (keep your existing logic)
  double _calculateGrowthRate(int count) {
    if (count == 0) return 0.0;
    if (count < 10) return 5.5;
    if (count < 20) return 8.2;
    return 12.5;
  }

  List<Map<String, dynamic>> _generateActivities() {
    // Your existing activity generation logic
    return [];
  }

  Map<String, int> _generateReportStatus() {
    return {'completed': 85, 'in-progress': 25, 'pending': 15};
  }

  List<Map<String, dynamic>> _generateRecentActivities() {
    // Your existing recent activities logic
    return [];
  }

  List<Map<String, dynamic>> _generateRecentActivitiesTable() {
    // Your existing table activities logic
    return [];
  }

  // Optional: Add refresh method
  Future<void> refresh() async {
    _hasLoaded = false;
    await loadStats();
  }
}