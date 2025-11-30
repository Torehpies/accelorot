import 'package:flutter/material.dart';
import '../../../../../data/models/machine_model.dart';
import '../../../../../data/repositories/machine_repository.dart';
import '../../../../../data/services/firebase/firebase_machine_service.dart';

class AdminMachineController extends ChangeNotifier {
  // ==================== DEPENDENCIES ====================
  
  final MachineRepository _repository;
  final FirebaseMachineService _service;

  AdminMachineController({
    MachineRepository? repository,
    FirebaseMachineService? service,
  })  : _repository = repository ?? MachineRepository(FirebaseMachineService()),
        _service = service ?? FirebaseMachineService();

  // ==================== STATE ====================

  List<MachineModel> _allMachines = [];
  bool _showArchived = false;
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';
  bool _isAuthenticated = false;
  int _displayLimit = 5;
  static const int _pageSize = 5;

  final TextEditingController searchController = TextEditingController();

  // ==================== GETTERS ====================

  List<MachineModel> get machines => _allMachines;
  bool get showArchived => _showArchived;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  bool get isAuthenticated => _isAuthenticated;

  /// Get filtered machines based on view (active/archived) and search
  List<MachineModel> get filteredMachines {
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

  // ==================== INITIALIZATION ====================

  Future<void> initialize() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      _isAuthenticated = _service.currentUserId != null;

      if (_isAuthenticated) {
        await _fetchMachinesByTeamId(_service.currentUserId!);
      } else {
        // Not authenticated - fetch all for preview
        _allMachines = await _repository.getMachinesByTeam('');
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
      _allMachines = await _repository.getMachinesByTeam(teamId);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to fetch machines: $e';
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    try {
      _isAuthenticated = _service.currentUserId != null;

      if (_isAuthenticated) {
        await _fetchMachinesByTeamId(_service.currentUserId!);
      } else {
        _allMachines = await _repository.getMachinesByTeam('');
      }

      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to refresh: $e';
      notifyListeners();
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

  /// Add new machine
  Future<void> addMachine({
    required String machineName,
    required String machineId,
  }) async {
    try {
      if (!_isAuthenticated) {
        throw Exception('You must be logged in to add machines');
      }

      final currentUserId = _service.currentUserId!;

      // Check if machine ID already exists
      final exists = await _repository.checkMachineExists(machineId);
      if (exists) {
        throw Exception('Machine ID "$machineId" already exists');
      }

      final request = CreateMachineRequest(
        machineId: machineId,
        machineName: machineName,
        teamId: currentUserId,
      );

      await _repository.createMachine(request);

      await Future.delayed(const Duration(milliseconds: 1000));
      await refresh();
    } catch (e) {
      _errorMessage = 'Failed to add machine: $e';
      notifyListeners();
      rethrow;
    }
  }

  /// Update existing machine
  Future<void> updateMachine({
    required String machineId,
    required String machineName,
  }) async {
    try {
      if (!_isAuthenticated) {
        throw Exception('You must be logged in to update machines');
      }

      final request = UpdateMachineRequest(
        machineId: machineId,
        machineName: machineName,
      );

      await _repository.updateMachine(request);

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
      if (!_isAuthenticated) {
        throw Exception('You must be logged in to archive machines');
      }

      await _repository.archiveMachine(machineId);
      await Future.delayed(const Duration(milliseconds: 300));
      await refresh();
    } catch (e) {
      _errorMessage = 'Failed to archive machine: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> restoreMachine(String machineId) async {
    try {
      if (!_isAuthenticated) {
        throw Exception('You must be logged in to restore machines');
      }

      await _repository.restoreMachine(machineId);
      await Future.delayed(const Duration(milliseconds: 300));
      await refresh();
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

  /// Check if a machine ID already exists
  Future<bool> machineExists(String machineId) async {
    try {
      return await _repository.checkMachineExists(machineId);
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