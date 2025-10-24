// lib/frontend/operator/machine_management/admin_machine/controllers/admin_machine_controller.dart

import 'package:flutter/material.dart';
import '../../models/machine_model.dart';
import '../../../../../services/machine_services/firestore_machine_service.dart';

class AdminMachineController extends ChangeNotifier {
  // ==================== STATE ====================
  
  List<MachineModel> _machines = [];
  List<Map<String, dynamic>> _teamMembers = []; // Changed from _users to _teamMembers
  final Map<String, bool> _expandedStates = {};
  bool _showArchived = false;
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';
  bool _isAuthenticated = false;

  // ==================== GETTERS ====================
  
  List<MachineModel> get machines => _machines;
  List<Map<String, dynamic>> get users => _teamMembers; // Keep getter name for backward compatibility
  bool get showArchived => _showArchived;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  bool get isAuthenticated => _isAuthenticated;

  /// Get filtered machines based on view (active/archived) and search
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
      final currentUserId = FirestoreMachineService.getCurrentUserId();
      _isAuthenticated = currentUserId != null;

      // Upload mock data if needed (works without auth)
      await FirestoreMachineService.uploadAllMockMachines();

      if (_isAuthenticated) {
        // Admin is logged in - fetch their team's machines and team members
        await Future.wait([
          _fetchMachinesByTeamId(currentUserId!),
          _fetchTeamMembers(currentUserId), // Changed from _fetchUsers
        ]);
      } else {
        // Not logged in - show all machines for preview
        await Future.wait([
          _fetchAllMachines(),
          _fetchTeamMembers(''), // Empty list when not authenticated
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
  
  Future<void> _fetchMachinesByTeamId(String teamId) async {
    try {
      _machines = await FirestoreMachineService.getMachinesByTeamId(teamId);
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

  /// Fetch team members from teams/{teamId}/members subcollection
  /// Only fetches active (non-archived) members
  Future<void> _fetchTeamMembers(String teamId) async {
    try {
      if (teamId.isEmpty) {
        _teamMembers = [];
        notifyListeners();
        return;
      }

      _teamMembers = await FirestoreMachineService.getTeamMembers(teamId);
      notifyListeners();
    } catch (e) {
      // Don't set error for team members fetch, it's not critical
      _teamMembers = [];
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    final currentUserId = FirestoreMachineService.getCurrentUserId();
    _isAuthenticated = currentUserId != null;
    
    if (_isAuthenticated) {
      await Future.wait([
        _fetchMachinesByTeamId(currentUserId!),
        _fetchTeamMembers(currentUserId),
      ]);
    } else {
      await Future.wait([
        _fetchAllMachines(),
        _fetchTeamMembers(''),
      ]);
    }
  }

  // ==================== UI STATE MANAGEMENT ====================
  
  void setShowArchived(bool value) {
    _showArchived = value;
    _searchQuery = ''; // Clear search when switching views
    notifyListeners();
  }

  void toggleExpanded(String machineId) {
    _expandedStates[machineId] = !(_expandedStates[machineId] ?? false);
    notifyListeners();
  }

  /// Collapse a specific card (used after archive/restore)
  void _collapseCard(String machineId) {
    _expandedStates[machineId] = false;
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
  
  /// Add new machine (auto-sets teamId to admin's UID)
  Future<void> addMachine({
    required String machineName,
    required String machineId,
    required String userId,
  }) async {
    try {
      final currentUserId = FirestoreMachineService.getCurrentUserId();
      if (currentUserId == null) {
        throw Exception('You must be logged in to add machines');
      }

      // Check if machine ID already exists
      final exists = await FirestoreMachineService.machineExists(machineId);
      if (exists) {
        throw Exception('Machine ID "$machineId" already exists');
      }

      final machine = MachineModel(
        machineName: machineName,
        machineId: machineId,
        userId: userId,
        teamId: currentUserId, // Auto-set to admin's UID
        dateCreated: DateTime.now(),
        isArchived: false,
      );

      await FirestoreMachineService.addMachine(machine);
      await refresh();
    } catch (e) {
      _errorMessage = 'Failed to add machine: $e';
      notifyListeners();
      rethrow;
    }
  }

  /// Update existing machine (can change name and assigned user)
  Future<void> updateMachine({
    required String machineId,
    required String machineName,
    required String userId,
  }) async {
    try {
      final currentUserId = FirestoreMachineService.getCurrentUserId();
      if (currentUserId == null) {
        throw Exception('You must be logged in to update machines');
      }

      // Find the existing machine to preserve immutable fields
      final existingMachine = _machines.firstWhere(
        (m) => m.machineId == machineId,
      );

      final updatedMachine = existingMachine.copyWith(
        machineName: machineName,
        userId: userId,
        // teamId and machineId remain unchanged
      );

      await FirestoreMachineService.updateMachine(updatedMachine);
      await refresh();
    } catch (e) {
      _errorMessage = 'Failed to update machine: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> archiveMachine(String machineId) async {
    try {
      final currentUserId = FirestoreMachineService.getCurrentUserId();
      if (currentUserId == null) {
        throw Exception('You must be logged in to archive machines');
      }

      // Collapse the card before archiving
      _collapseCard(machineId);
      
      await FirestoreMachineService.deleteMachine(machineId);
      await refresh();
    } catch (e) {
      _errorMessage = 'Failed to archive machine: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> restoreMachine(String machineId) async {
    try {
      final currentUserId = FirestoreMachineService.getCurrentUserId();
      if (currentUserId == null) {
        throw Exception('You must be logged in to restore machines');
      }

      // Collapse the card before restoring
      _collapseCard(machineId);
      
      await FirestoreMachineService.restoreMachine(machineId);
      await refresh();
    } catch (e) {
      _errorMessage = 'Failed to restore machine: $e';
      notifyListeners();
      rethrow;
    }
  }

  // ==================== HELPER METHODS ====================
  
  /// Get member name by userId
  /// Now uses 'name' field from team members instead of 'fullName' from users
  String? getUserName(String userId) {
    final member = _teamMembers.firstWhere(
      (m) => m['uid'] == userId,
      orElse: () => {},
    );
    return member.isNotEmpty ? member['name'] : null;
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}