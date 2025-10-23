// lib/frontend/operator/machine_management/operator_machine/controllers/operator_machine_controller.dart

import 'package:flutter/material.dart';
import '../../models/machine_model.dart';
import '../../../../../services/machine_services/mock_data/firestore_machine_service.dart';

class OperatorMachineController extends ChangeNotifier {
  // ==================== STATE ====================
  
  List<MachineModel> _machines = [];
  List<Map<String, dynamic>> _users = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';
  bool _isAuthenticated = false;

  // ==================== GETTERS ====================
  
  List<MachineModel> get machines => _machines;
  List<Map<String, dynamic>> get users => _users;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  bool get isAuthenticated => _isAuthenticated;

  /// Get filtered machines based on search query
  /// Operators see ALL their machines (active + archived)
  /// Archived machines are shown as disabled
  List<MachineModel> get filteredMachines {
    if (_searchQuery.isEmpty) {
      return _machines;
    }

    return _machines.where((m) {
      final query = _searchQuery.toLowerCase();
      return m.machineName.toLowerCase().contains(query) ||
          m.machineId.toLowerCase().contains(query);
    }).toList();
  }

  // Get active machines count
  int get activeMachinesCount =>
      _machines.where((m) => !m.isArchived).length;

  // Get archived machines count
  int get archivedMachinesCount =>
      _machines.where((m) => m.isArchived).length;

  // ==================== INITIALIZATION ====================
  
  Future<void> initialize() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final currentUserId = FirestoreMachineService.getCurrentUserId();
      _isAuthenticated = currentUserId != null;

      // Upload mock data if needed (works without auth)
      await FirestoreMachineService.uploadAllMockMachines();

      if (_isAuthenticated) {
        // User is logged in - fetch their specific machines
        await Future.wait([
          _fetchMachinesByUserId(currentUserId!),
          _fetchUsers(),
        ]);
      } else {
        // Not logged in - show mock/all machines for preview
        await Future.wait([
          _fetchAllMachines(),
          _fetchUsers(),
        ]);
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load machines: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  // ==================== FETCH OPERATIONS ====================
  
  Future<void> _fetchMachinesByUserId(String userId) async {
    try {
      _machines = await FirestoreMachineService.getMachinesByUserId(userId);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to fetch machines: $e';
      notifyListeners();
    }
  }

  Future<void> _fetchAllMachines() async {
    try {
      // Fetch all machines for preview when not authenticated
      _machines = await FirestoreMachineService.getAllMachines();
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to fetch machines: $e';
      notifyListeners();
    }
  }

  Future<void> _fetchUsers() async {
    try {
      _users = await FirestoreMachineService.getOperatorsAndAdmins();
      notifyListeners();
    } catch (e) {
      // Don't set error for users fetch, it's not critical
      _users = [];
      notifyListeners();
    }
  }

  // Refresh machines list
  Future<void> refresh() async {
    final currentUserId = FirestoreMachineService.getCurrentUserId();
    _isAuthenticated = currentUserId != null;
    
    if (_isAuthenticated) {
      await _fetchMachinesByUserId(currentUserId!);
    } else {
      await _fetchAllMachines();
    }
  }

  // ==================== SEARCH ====================
  
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    notifyListeners();
  }

  // ==================== HELPER METHODS ====================
  
  String? getUserName(String userId) {
    final user = _users.firstWhere(
      (u) => u['uid'] == userId,
      orElse: () => {},
    );
    return user.isNotEmpty ? user['fullName'] : null;
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}