// lib/frontend/operator/machine_management/controllers/machine_controller.dart

import 'package:flutter/material.dart';
import '../models/machine_model.dart';
import '../../../../../services/machine_services/mock_data/firestore_machine_service.dart';

class MachineController extends ChangeNotifier {
  // State
  List<MachineModel> _machines = [];
  List<Map<String, dynamic>> _users = [];
  final Map<String, bool> _expandedStates = {}; // Track expansion per machineId
  bool _showArchived = false;
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';

  // Getters
  List<MachineModel> get machines => _machines;
  List<Map<String, dynamic>> get users => _users;
  bool get showArchived => _showArchived;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;

  // Get filtered machines based on view (active/archived) and search
  List<MachineModel> get filteredMachines {
    var filtered = _showArchived
        ? _machines.where((m) => m.isArchived).toList()
        : _machines.where((m) => !m.isArchived).toList();

    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((m) {
        final query = _searchQuery.toLowerCase();
        return m.machineName.toLowerCase().contains(query) ||
            m.machineId.toLowerCase().contains(query);
      }).toList();
    }

    return filtered;
  }

  // Check if machine is expanded
  bool isExpanded(String machineId) => _expandedStates[machineId] ?? false;

  // ==================== INITIALIZATION ====================
  Future<void> initialize() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Upload mock data if none exists
      await FirestoreMachineService.uploadAllMockMachines();

      // Fetch machines and users
      await Future.wait([
        fetchMachines(),
        fetchUsers(),
      ]);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to initialize: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // ==================== FETCH OPERATIONS ====================
  Future<void> fetchMachines() async {
    try {
      _machines = await FirestoreMachineService.getAllMachines();
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to fetch machines: $e';
      notifyListeners();
    }
  }

  Future<void> fetchUsers() async {
    try {
      _users = await FirestoreMachineService.getOperatorsAndAdmins();
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to fetch users: $e';
      notifyListeners();
    }
  }

  // ==================== UI STATE MANAGEMENT ====================
  void toggleView() {
    _showArchived = !_showArchived;
    _searchQuery = ''; // Clear search when switching views
    notifyListeners();
  }

  void setShowArchived(bool value) {
    _showArchived = value;
    _searchQuery = ''; // Clear search when switching views
    notifyListeners();
  }

  void toggleExpanded(String machineId) {
    _expandedStates[machineId] = !(_expandedStates[machineId] ?? false);
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    notifyListeners();
  }

  // ==================== CRUD OPERATIONS ====================
  Future<void> addMachine({
    required String machineName,
    required String machineId,
    required String userId,
  }) async {
    try {
      final machine = MachineModel(
        machineName: machineName,
        machineId: machineId,
        userId: userId,
        dateCreated: DateTime.now(),
        isArchived: false,
      );

      await FirestoreMachineService.addMachine(machine);
      await fetchMachines();
    } catch (e) {
      _errorMessage = 'Failed to add machine: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> archiveMachine(String machineId) async {
    try {
      await FirestoreMachineService.updateMachineArchiveStatus(machineId, true);
      await fetchMachines();
    } catch (e) {
      _errorMessage = 'Failed to archive machine: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> restoreMachine(String machineId) async {
    try {
      await FirestoreMachineService.updateMachineArchiveStatus(machineId, false);
      await fetchMachines();
    } catch (e) {
      _errorMessage = 'Failed to restore machine: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteMachine(String machineId) async {
    try {
      await FirestoreMachineService.deleteMachine(machineId);
      await fetchMachines();
    } catch (e) {
      _errorMessage = 'Failed to delete machine: $e';
      notifyListeners();
      rethrow;
    }
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