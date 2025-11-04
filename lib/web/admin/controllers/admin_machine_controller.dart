// lib/web/admin/controllers/admin_machine_controller.dart

import 'package:flutter/material.dart';
import '../models/admin_machine_model.dart' as AdminModel;
import '../../../../../services/machine_services/firestore_machine_service.dart';
import '../../../frontend/operator/machine_management/models/machine_model.dart' as OperatorModel;

class AdminMachineController extends ChangeNotifier {
  // ==================== STATE ====================
  
  List<AdminModel.MachineModel> _allMachines = [];
  bool _showArchived = false;
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';
  bool _isAuthenticated = false;
  int _displayLimit = 5;
  static const int _pageSize = 5;

  final TextEditingController searchController = TextEditingController();

  // ==================== CONVERTERS ====================
  
  /// Convert Operator MachineModel to Admin MachineModel
  AdminModel.MachineModel _convertToAdminModel(OperatorModel.MachineModel operatorModel) {
    return AdminModel.MachineModel(
      machineName: operatorModel.machineName,
      machineId: operatorModel.machineId,
      userId: operatorModel.userId,
      teamId: operatorModel.teamId,
      dateCreated: operatorModel.dateCreated,
      isArchived: operatorModel.isArchived,
    );
  }

  /// Convert list of Operator MachineModels to Admin MachineModels
  List<AdminModel.MachineModel> _convertList(List<OperatorModel.MachineModel> operatorList) {
    return operatorList.map(_convertToAdminModel).toList();
  }

  /// Convert Admin MachineModel to Operator MachineModel
  OperatorModel.MachineModel _convertToOperatorModel(AdminModel.MachineModel adminModel) {
    return OperatorModel.MachineModel(
      machineName: adminModel.machineName,
      machineId: adminModel.machineId,
      userId: adminModel.userId,
      teamId: adminModel.teamId,
      dateCreated: adminModel.dateCreated,
      isArchived: adminModel.isArchived,
    );
  }

  // ==================== GETTERS ====================
  
  List<AdminModel.MachineModel> get machines => _allMachines;
  bool get showArchived => _showArchived;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  bool get isAuthenticated => _isAuthenticated;

  /// Get filtered machines based on view (active/archived) and search
  List<AdminModel.MachineModel> get filteredMachines {
    var filtered = _showArchived
        ? _allMachines.where((m) => m.isArchived).toList()
        : _allMachines.where((m) => !m.isArchived).toList();

    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((m) {
        final query = _searchQuery.toLowerCase();
        return m.machineName.toLowerCase().contains(query) ||
            m.machineId.toLowerCase().contains(query);
      }).toList();
    }

    return filtered;
  }

  /// Get machines to display with pagination
  List<AdminModel.MachineModel> get displayedMachines {
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
        // Admin is logged in - fetch their team's machines
        await _fetchMachinesByTeamId(currentUserId!);
      } else {
        // Not logged in - show all machines for preview
        await _fetchAllMachines();
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
      final operatorMachines = await FirestoreMachineService.getMachinesByTeamId(teamId);
      _allMachines = _convertList(operatorMachines);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to fetch machines: $e';
      notifyListeners();
    }
  }

  Future<void> _fetchAllMachines() async {
    try {
      // Fetch all machines for preview when not authenticated
      final operatorMachines = await FirestoreMachineService.getAllMachines();
      _allMachines = _convertList(operatorMachines);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to fetch machines: $e';
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    final currentUserId = FirestoreMachineService.getCurrentUserId();
    _isAuthenticated = currentUserId != null;
    
    if (_isAuthenticated) {
      await _fetchMachinesByTeamId(currentUserId!);
    } else {
      await _fetchAllMachines();
    }
  }

  // ==================== UI STATE MANAGEMENT ====================
  
  void setShowArchived(bool value) {
    _showArchived = value;
    _searchQuery = '';
    searchController.clear();
    resetPagination();
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    resetPagination();
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    searchController.clear();
    resetPagination();
    notifyListeners();
  }

  // ==================== PAGINATION ====================
  
  void loadMore() {
    _displayLimit += _pageSize;
    notifyListeners();
  }

  void resetPagination() {
    _displayLimit = _pageSize;
  }

  // ==================== CRUD OPERATIONS ====================
  
  /// Add new machine (auto-sets teamId to admin's UID)
  Future<void> addMachine({
    required String machineName,
    required String machineId,
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

      // Create admin model first
      final adminMachine = AdminModel.MachineModel(
        machineName: machineName,
        machineId: machineId,
        userId: '', // No longer used - machines are team-wide
        teamId: currentUserId, // Auto-set to admin's UID
        dateCreated: DateTime.now(),
        isArchived: false,
      );

      // Convert to operator model for service
      final operatorMachine = _convertToOperatorModel(adminMachine);
      await FirestoreMachineService.addMachine(operatorMachine);
      
      // Delay before refresh
      await Future.delayed(const Duration(milliseconds: 1000));
      await refresh();
    } catch (e) {
      _errorMessage = 'Failed to add machine: $e';
      notifyListeners();
      rethrow;
    }
  }

  /// Update existing machine (can change name only)
  Future<void> updateMachine({
    required String machineId,
    required String machineName,
  }) async {
    try {
      final currentUserId = FirestoreMachineService.getCurrentUserId();
      if (currentUserId == null) {
        throw Exception('You must be logged in to update machines');
      }

      // Find the existing machine to preserve immutable fields
      final existingMachine = _allMachines.firstWhere(
        (m) => m.machineId == machineId,
      );

      final updatedAdminMachine = existingMachine.copyWith(
        machineName: machineName,
        userId: '', // Keep empty - not used anymore
      );

      // Convert to operator model for service
      final operatorMachine = _convertToOperatorModel(updatedAdminMachine);
      await FirestoreMachineService.updateMachine(operatorMachine);
      
      // Delay before refresh
      await Future.delayed(const Duration(milliseconds: 1000));
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

      // Delay before executing archive
      await Future.delayed(const Duration(milliseconds: 300));
      
      await FirestoreMachineService.deleteMachine(machineId);
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

      // Delay before executing restore
      await Future.delayed(const Duration(milliseconds: 300));
      
      await FirestoreMachineService.restoreMachine(machineId);
    } catch (e) {
      _errorMessage = 'Failed to restore machine: $e';
      notifyListeners();
      rethrow;
    }
  }

  // ==================== HELPER METHODS ====================
  
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Check if a machine ID already exists (used by AddMachineModal)
  Future<bool> machineExists(String machineId) async {
    try {
      return await FirestoreMachineService.machineExists(machineId);
    } catch (e) {
      debugPrint('Error checking machine existence: $e');
      return false;
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}