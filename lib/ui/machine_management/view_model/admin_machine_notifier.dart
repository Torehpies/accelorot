// lib/ui/machine_management/view_model/admin_machine_notifier.dart

import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../data/models/machine_model.dart';
import '../../../data/repositories/machine_repository/machine_repository.dart';
import '../../../data/providers/machine_providers.dart';

part 'admin_machine_notifier.g.dart';

// Updated enum: inactive → suspended
enum MachineFilterTab {
  all,
  active,
  suspended,  // Changed from 'inactive'
  archived,
}

class AdminMachineState {
  final List<MachineModel> machines;
  final MachineFilterTab selectedTab;
  final bool isLoading;
  final String? errorMessage;
  final String searchQuery;
  final int displayLimit;
  
  // Pagination
  final int currentPage;
  final int itemsPerPage;
  
  // Sorting
  final String? sortColumn;
  final bool sortAscending;

  const AdminMachineState({
    this.machines = const [],
    this.selectedTab = MachineFilterTab.all,
    this.isLoading = false,
    this.errorMessage,
    this.searchQuery = '',
    this.displayLimit = 5,
    this.currentPage = 1,
    this.itemsPerPage = 10,
    this.sortColumn,
    this.sortAscending = true,
  });

  AdminMachineState copyWith({
    List<MachineModel>? machines,
    MachineFilterTab? selectedTab,
    bool? isLoading,
    String? errorMessage,
    String? searchQuery,
    int? displayLimit,
    int? currentPage,
    int? itemsPerPage,
    String? sortColumn,
    bool? sortAscending,
  }) {
    return AdminMachineState(
      machines: machines ?? this.machines,
      selectedTab: selectedTab ?? this.selectedTab,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      searchQuery: searchQuery ?? this.searchQuery,
      displayLimit: displayLimit ?? this.displayLimit,
      currentPage: currentPage ?? this.currentPage,
      itemsPerPage: itemsPerPage ?? this.itemsPerPage,
      sortColumn: sortColumn ?? this.sortColumn,
      sortAscending: sortAscending ?? this.sortAscending,
    );
  }

  List<MachineModel> get filteredMachines {
    var filtered = machines;

    // Filter by tab
    switch (selectedTab) {
      case MachineFilterTab.all:
        filtered = machines.where((m) => !m.isArchived).toList();
        break;
      case MachineFilterTab.active:
        filtered = machines
            .where((m) => !m.isArchived && m.status == MachineStatus.active)
            .toList();
        break;
      case MachineFilterTab.suspended:
        // Suspended = underMaintenance status
        filtered = machines
            .where((m) => !m.isArchived && m.status == MachineStatus.underMaintenance)
            .toList();
        break;
      case MachineFilterTab.archived:
        filtered = machines.where((m) => m.isArchived).toList();
        break;
    }

    // Filter by search query
    if (searchQuery.isNotEmpty) {
      filtered = filtered.where((m) {
        final query = searchQuery.toLowerCase();
        return m.machineName.toLowerCase().contains(query) ||
            m.machineId.toLowerCase().contains(query);
      }).toList();
    }

    // Apply sorting
    if (sortColumn != null) {
      filtered = _sortMachines(filtered, sortColumn!, sortAscending);
    }

    return filtered;
  }

  // For load-more pattern (keep for now)
  List<MachineModel> get displayedMachines {
    return filteredMachines.take(displayLimit).toList();
  }

  bool get hasMoreToLoad {
    return displayedMachines.length < filteredMachines.length;
  }

  int get remainingCount {
    return filteredMachines.length - displayedMachines.length;
  }

  // For true pagination
  List<MachineModel> get paginatedMachines {
    final startIndex = (currentPage - 1) * itemsPerPage;
    final endIndex = startIndex + itemsPerPage;
    
    if (startIndex >= filteredMachines.length) return [];
    
    return filteredMachines.sublist(
      startIndex,
      endIndex > filteredMachines.length ? filteredMachines.length : endIndex,
    );
  }

  int get totalPages {
    if (filteredMachines.isEmpty) return 1;
    return (filteredMachines.length / itemsPerPage).ceil();
  }

  // Sort machines based on column
  List<MachineModel> _sortMachines(List<MachineModel> machines, String column, bool ascending) {
    final sorted = List<MachineModel>.from(machines);

    switch (column) {
      case 'machineId':
        sorted.sort((a, b) => a.machineId.compareTo(b.machineId));
        break;
      case 'name':
        sorted.sort((a, b) => a.machineName.compareTo(b.machineName));
        break;
      case 'date':
        sorted.sort((a, b) => a.dateCreated.compareTo(b.dateCreated));
        break;
      default:
        return sorted;
    }

    return ascending ? sorted : sorted.reversed.toList();
  }
}

@riverpod
class AdminMachineNotifier extends _$AdminMachineNotifier {
  static const int _pageSize = 5;
  
  MachineRepository get _repository => ref.read(machineRepositoryProvider);

  @override
  AdminMachineState build() {
    return const AdminMachineState();
  }

  Future<void> initialize(String teamId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final machines = await _repository.getMachinesByTeam(teamId)
          .timeout(const Duration(seconds: 10));
      state = state.copyWith(machines: machines, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Failed to load: ${e.toString().replaceAll('Exception:', '').trim()}',
        isLoading: false,
      );
    }
  }

  Future<void> refresh(String teamId) async {
    try {
      final machines = await _repository.getMachinesByTeam(teamId)
          .timeout(const Duration(seconds: 10));
      state = state.copyWith(machines: machines);
    } catch (e) {
      state = state.copyWith(errorMessage: 'Failed to refresh: ${e.toString().replaceAll('Exception:', '').trim()}');
    }
  }

  void setFilterTab(MachineFilterTab tab) {
    state = state.copyWith(
      selectedTab: tab,
      searchQuery: '',
      displayLimit: _pageSize,
      currentPage: 1,  // Reset to page 1
    );
  }

  void setSearchQuery(String query) {
    state = state.copyWith(
      searchQuery: query,
      displayLimit: _pageSize,
      currentPage: 1,  // Reset to page 1
    );
  }

  void clearSearch() {
    state = state.copyWith(
      searchQuery: '',
      displayLimit: _pageSize,
      currentPage: 1,
    );
  }

  void loadMore() {
    state = state.copyWith(displayLimit: state.displayLimit + _pageSize);
  }

  // Pagination methods
  void onPageChanged(int page) {
    state = state.copyWith(currentPage: page);
  }

  void onItemsPerPageChanged(int itemsPerPage) {
    state = state.copyWith(
      itemsPerPage: itemsPerPage,
      currentPage: 1,  // Reset to page 1
    );
  }

  // Sorting method
  void onSort(String column) {
    if (state.sortColumn == column) {
      // Toggle sort direction
      state = state.copyWith(sortAscending: !state.sortAscending);
    } else {
      // New column, default ascending
      state = state.copyWith(
        sortColumn: column,
        sortAscending: true,
      );
    }
  }

  Future<void> addMachine({
    required String teamId,
    required String machineName,
    required String machineId,
    required List<String> assignedUserIds,
  }) async {
    try {
      final exists = await _repository.checkMachineExists(machineId);
      if (exists) {
        throw Exception('Machine ID "$machineId" already exists');
      }

      final request = CreateMachineRequest(
        machineId: machineId,
        machineName: machineName,
        teamId: teamId,
        assignedUserIds: assignedUserIds,
        status: MachineStatus.active,
      );

      await _repository.createMachine(request);
      await Future.delayed(const Duration(milliseconds: 1000));
      await refresh(teamId);
    } catch (e) {
      state = state.copyWith(errorMessage: 'Failed to add machine: $e');
      rethrow;
    }
  }

  Future<void> updateMachine({
    required String teamId,
    required String machineId,
    String? machineName,
    MachineStatus? status,
    List<String>? assignedUserIds,
  }) async {
    try {
      final request = UpdateMachineRequest(
        machineId: machineId,
        machineName: machineName,
        status: status,
        assignedUserIds: assignedUserIds,
      );

      await _repository.updateMachine(request);
      await Future.delayed(const Duration(milliseconds: 1000));
      await refresh(teamId);
    } catch (e) {
      state = state.copyWith(errorMessage: 'Failed to update machine: $e');
      rethrow;
    }
  }

  Future<void> archiveMachine(String teamId, String machineId) async {
    try {
      await _repository.archiveMachine(machineId);
      await Future.delayed(const Duration(milliseconds: 300));
      await refresh(teamId);
    } catch (e) {
      state = state.copyWith(errorMessage: 'Failed to archive machine: $e');
      rethrow;
    }
  }

  Future<void> restoreMachine(String teamId, String machineId) async {
    try {
      await _repository.restoreMachine(machineId);
      await Future.delayed(const Duration(milliseconds: 300));
      await refresh(teamId);
    } catch (e) {
      state = state.copyWith(errorMessage: 'Failed to restore machine: $e');
      rethrow;
    }
  }

  Future<bool> machineExists(String machineId) async {
    try {
      return await _repository.checkMachineExists(machineId);
    } catch (e) {
      debugPrint('Error checking machine existence: $e');
      return false;
    }
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}