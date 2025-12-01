// lib/web/admin/controllers/admin_machine_controller.dart

import 'package:flutter/material.dart';
import '../../../data/models/machine_model.dart' as admin_model;
import '../../../data/services/firebase/firebase_machine_service.dart'; 
import '../../../data/repositories/machine_repository.dart'; 
import '../../../data/models/machine_model.dart' as operator_model;

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

  List<admin_model.MachineModel> _allMachines = [];
  bool _showArchived = false;
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';
  bool _isAuthenticated = false;
  int _displayLimit = 5;
  static const int _pageSize = 5;

  final TextEditingController searchController = TextEditingController();

  // ==================== CONVERTERS ====================

  admin_model.MachineModel _convertToAdminModel(
    operator_model.MachineModel operatorModel,
  ) {
    return admin_model.MachineModel(
      machineName: operatorModel.machineName,
      machineId: operatorModel.machineId,
      userId: operatorModel.userId ?? '',
      teamId: operatorModel.teamId,
      dateCreated: operatorModel.dateCreated,
      isArchived: operatorModel.isArchived,
    );
  }

  List<admin_model.MachineModel> _convertList(
    List<operator_model.MachineModel> operatorList,
  ) {
    return operatorList.map(_convertToAdminModel).toList();
  }

  // ==================== GETTERS ====================

  List<admin_model.MachineModel> get machines => _allMachines;
  bool get showArchived => _showArchived;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  bool get isAuthenticated => _isAuthenticated;

  List<admin_model.MachineModel> get filteredMachines {
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

  List<admin_model.MachineModel> get displayedMachines {
    return filteredMachines.take(_displayLimit).toList();
  }

  bool get hasMoreToLoad {
    return displayedMachines.length < filteredMachines.length;
  }

  int get remainingCount {
    return filteredMachines.length - displayedMachines.length;
  }

  // ==================== INITIALIZATION ====================

  Future<void> initialize() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final currentUserId = _service.currentUserId;
      _isAuthenticated = currentUserId != null;

      if (_isAuthenticated) {
        await _fetchMachinesByTeamId(currentUserId!);
      } else {
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
      final operatorMachines = await _repository.getMachinesByTeam(teamId);
      _allMachines = _convertList(operatorMachines);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to fetch machines: $e';
      notifyListeners();
    }
  }

  Future<void> _fetchAllMachines() async {
    try {
      final operatorMachines = await _repository.getMachinesByTeam('');
      _allMachines = _convertList(operatorMachines);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to fetch machines: $e';
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    final currentUserId = _service.currentUserId;
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

  Future<void> addMachine({
    required String machineName,
    required String machineId,
  }) async {
    try {
      final currentUserId = _service.currentUserId;
      if (currentUserId == null) {
        throw Exception('You must be logged in to add machines');
      }

      final exists = await _repository.checkMachineExists(machineId);
      if (exists) {
        throw Exception('Machine ID "$machineId" already exists');
      }

      final request = operator_model.CreateMachineRequest(
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

  Future<void> updateMachine({
    required String machineId,
    required String machineName,
  }) async {
    try {
      final currentUserId = _service.currentUserId;
      if (currentUserId == null) {
        throw Exception('You must be logged in to update machines');
      }

      final request = operator_model.UpdateMachineRequest(
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
      final currentUserId = _service.currentUserId;
      if (currentUserId == null) {
        throw Exception('You must be logged in to archive machines');
      }

      await Future.delayed(const Duration(milliseconds: 300));
      await _repository.archiveMachine(machineId);
      await refresh();
    } catch (e) {
      _errorMessage = 'Failed to archive machine: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> restoreMachine(String machineId) async {
    try {
      final currentUserId = _service.currentUserId;
      if (currentUserId == null) {
        throw Exception('You must be logged in to restore machines');
      }

      await Future.delayed(const Duration(milliseconds: 300));
      await _repository.restoreMachine(machineId);
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