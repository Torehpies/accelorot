// lib/ui/web_admin_home/view_model/web_admin_dashboard_view_model.dart
import 'package:flutter/foundation.dart';
import '../../../data/repositories/dashboard_repository.dart';

class WebAdminDashboardViewModel extends ChangeNotifier {
  final DashboardRepository _repository;
  final String teamId;

  // State variables
  bool _isLoading = true;
  String? _errorMessage;
  
  int totalOperators = 0;
  int totalMachines = 0;
  int totalReports = 0;
  double operatorGrowthRate = 0.0;
  double machineGrowthRate = 0.0;
  double reportGrowthRate = 0.0;

  List<Map<String, dynamic>> activities = [];
  Map<String, int> reportStatus = {
    'Open': 0,
    'In Progress': 0,
    'Closed': 0,
    'Pending': 0,
  };
  List<Map<String, String>> recentActivities = [];

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<String> get reportLegends => reportStatus.keys.toList();

  WebAdminDashboardViewModel(this._repository, this.teamId) {
    _loadDashboardData();
  }

  /// Load dashboard data from repository
  Future<void> _loadDashboardData() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final data = await _repository.fetchDashboardData(teamId);

      // Update state with fetched data
      totalOperators = data.totalOperators;
      totalMachines = data.totalMachines;
      totalReports = data.reportStatus.values.fold(0, (sum, count) => sum + count);
      reportStatus = data.reportStatus;
      activities = data.activities;
      recentActivities = data.recentActivities;

      // Calculate growth rates (placeholder - you can implement actual logic)
      // For now, we'll use mock values or calculate based on historical data
      operatorGrowthRate = 0.0;
      machineGrowthRate = 0.0; 
      reportGrowthRate = 0.0; 

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load dashboard data: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Refresh dashboard data
  Future<void> refresh() async {
    await _loadDashboardData();
  }
}