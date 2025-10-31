// lib/frontend/operator/machine_management/operator_machine/controllers/operator_machine_controller.dart

import 'package:flutter/material.dart';
import '../../models/machine_model.dart';
import '../../../../../services/machine_services/firestore_machine_service.dart';

class OperatorMachineController extends ChangeNotifier {
  // ==================== STATE ====================
  
  List<MachineModel> _allMachines = [];
  List<Map<String, dynamic>> _users = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';
  bool _isAuthenticated = false;
  final String? viewingOperatorId;
  int _displayLimit = 10;
  static const int _pageSize = 10;

  OperatorMachineController({this.viewingOperatorId});

  // ==================== GETTERS ====================
  
  List<MachineModel> get machines => _allMachines;
  List<Map<String, dynamic>> get users => _users;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  bool get isAuthenticated => _isAuthenticated;

  /// Get filtered machines based on search query
  List<MachineModel> get filteredMachines {
    if (_searchQuery.isEmpty) {
      return _allMachines;
    }

    return _allMachines.where((m) {
      final query = _searchQuery.toLowerCase();
      return m.machineName.toLowerCase().contains(query) ||
          m.machineId.toLowerCase().contains(query);
    }).toList();
  }

  /// Get machines to display with pagination
  List<MachineModel> get displayedMachines {
    return filteredMachines.take(_displayLimit).toList();
  }

  /// Check if there are more machines to load
  bool get hasMoreToLoad {
    return displayedMachines.length < filteredMachines.length;
  }

  /// Get count of remaining machines
  int get remainingCount {
    return filteredMachines.length - displayedMachines.length;
  }

  // Get active machines count
  int get activeMachinesCount =>
      _allMachines.where((m) => !m.isArchived).length;

  // Get archived machines count
  int get archivedMachinesCount =>
      _allMachines.where((m) => m.isArchived).length;

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

      final targetUserId = viewingOperatorId ?? currentUserId;

      if (targetUserId != null) {
        // Fetch ALL team machines for this operator
        await Future.wait([
          _fetchMachinesByOperatorId(targetUserId),
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
  
  /// Fetch all team machines for this operator
  Future<void> _fetchMachinesByOperatorId(String operatorId) async {
    try {
      _allMachines = await FirestoreMachineService.getMachinesByOperatorId(operatorId);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to fetch machines: $e';
      notifyListeners();
    }
  }

  Future<void> _fetchAllMachines() async {
    try {
      // Fetch all machines for preview when not authenticated
      _allMachines = await FirestoreMachineService.getAllMachines();
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to fetch machines: $e';
      notifyListeners();
    }
  }

  Future<void> _fetchUsers() async {
    try {
      _users = await FirestoreMachineService.getOperators();
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
    
    final targetUserId = viewingOperatorId ?? currentUserId;
    
    if (targetUserId != null) {
      await _fetchMachinesByOperatorId(targetUserId);
    } else {
      await _fetchAllMachines();
    }
  }

  // ==================== PAGINATION ====================
  
  void loadMore() {
    _displayLimit += _pageSize;
    notifyListeners();
  }

  void resetPagination() {
    _displayLimit = _pageSize;
    notifyListeners();
  }

  // ==================== SEARCH ====================
  
  void setSearchQuery(String query) {
    _searchQuery = query;
    resetPagination(); // Reset pagination when searching
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    resetPagination(); // Reset pagination when clearing search
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