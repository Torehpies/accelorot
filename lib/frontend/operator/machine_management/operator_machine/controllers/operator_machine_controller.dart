import 'package:flutter/material.dart';
import '../../../../../data/models/machine_model.dart';
import '../../../../../data/services/firebase/firebase_machine_service.dart'; // Changed
import '../../../../../data/repositories/machine_repository.dart'; // Added
import '../../../../../services/sess_service.dart';

class OperatorMachineController extends ChangeNotifier {
  // ==================== DEPENDENCIES ====================
  
  final MachineRepository _repository;
  final FirebaseMachineService _service;

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

  OperatorMachineController({
    this.viewingOperatorId,
    MachineRepository? repository,
    FirebaseMachineService? service,
  })  : _repository = repository ?? MachineRepository(FirebaseMachineService()),
        _service = service ?? FirebaseMachineService();

  // ==================== GETTERS ====================

  List<MachineModel> get machines => _allMachines;
  List<Map<String, dynamic>> get users => _users;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  bool get isAuthenticated => _isAuthenticated;

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

  List<MachineModel> get displayedMachines {
    return filteredMachines.take(_displayLimit).toList();
  }

  bool get hasMoreToLoad {
    return displayedMachines.length < filteredMachines.length;
  }

  int get remainingCount {
    return filteredMachines.length - displayedMachines.length;
  }

  int get activeMachinesCount =>
      _allMachines.where((m) => !m.isArchived).length;

  int get archivedMachinesCount =>
      _allMachines.where((m) => m.isArchived).length;

  // ==================== INITIALIZATION ====================

  Future<void> initialize() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final currentUserId = _service.currentUserId;
      _isAuthenticated = currentUserId != null;

      final targetUserId = viewingOperatorId ?? currentUserId;

      if (targetUserId != null) {
        await Future.wait([
          _fetchMachinesByOperatorId(targetUserId),
          _fetchUsers(),
        ]);
      } else {
        await Future.wait([_fetchAllMachines(), _fetchUsers()]);
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

  Future<void> _fetchMachinesByOperatorId(String operatorId) async {
    try {
      final sessionService = SessionService();
      final userData = await sessionService.getCurrentUserData();
      final teamId = userData?['teamId'] as String?;

      if (teamId != null && teamId.isNotEmpty) {
        _allMachines = await _repository.getMachinesByTeam(teamId);
      } else {
        _allMachines = await _repository.getMachinesByTeam('');
      }
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to fetch machines: $e';
      notifyListeners();
    }
  }

  Future<void> _fetchAllMachines() async {
    try {
      _allMachines = await _repository.getMachinesByTeam('');
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to fetch machines: $e';
      notifyListeners();
    }
  }

  Future<void> _fetchUsers() async {
    try {
      // TODO: Move this to a UserRepository when created
      _users = []; // For now, empty - implement when UserRepository exists
      notifyListeners();
    } catch (e) {
      _users = [];
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    final currentUserId = _service.currentUserId;
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
    resetPagination();
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    resetPagination();
    notifyListeners();
  }

  // ==================== HELPER METHODS ====================

  String? getUserName(String userId) {
    final user = _users.firstWhere((u) => u['uid'] == userId, orElse: () => {});
    return user.isNotEmpty ? user['fullName'] : null;
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}