// lib/ui/machine_management/view_model/machine_viewmodel.dart

import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../data/models/machine_model.dart';
import '../../../data/providers/machine_providers.dart';
import '../services/machine_aggregator_service.dart';
import '../services/machine_filter_service.dart';
import '../models/machine_state.dart';
import '../../activity_logs/models/activity_common.dart';

part 'machine_viewmodel.g.dart';

@riverpod
MachineAggregatorService machineAggregatorService(Ref ref) {
  final repository = ref.watch(machineRepositoryProvider);
  return MachineAggregatorService(machineRepo: repository);
}

@riverpod
class MachineViewModel extends _$MachineViewModel {
  // ========================================
  // MOBILE ONLY - Will be removed after mobile refactor
  // ========================================
  static const int _pageSize = 5;
  // ========================================

  late final MachineAggregatorService _aggregator;
  late final MachineFilterService _filterService;

  String? _currentTeamId;

  @override
  MachineState build() {
    _aggregator = ref.read(machineAggregatorServiceProvider);
    _filterService = MachineFilterService();
    
    return const MachineState();
  }

  // ===== INITIALIZATION =====

  Future<void> initialize(String teamId) async {
    _currentTeamId = teamId;
    
    state = state.copyWith(
      status: LoadingStatus.loading,
      errorMessage: null,
    );

    try {
      final isLoggedIn = await _aggregator.isUserLoggedIn();

      if (!isLoggedIn) {
        state = state.copyWith(
          status: LoadingStatus.success,
          isLoggedIn: false,
        );
        return;
      }

      state = state.copyWith(isLoggedIn: true);
      await loadMachines(teamId);
    } catch (e) {
      state = state.copyWith(
        status: LoadingStatus.error,
        errorMessage: 'Failed to load: ${e.toString().replaceAll('Exception:', '').trim()}',
      );
    }
  }

  // ===== DATA LOADING =====

  Future<void> loadMachines(String teamId) async {
    _currentTeamId = teamId;
    
    try {
      state = state.copyWith(status: LoadingStatus.loading);

      final machines = await _aggregator.getMachines(teamId);

      state = state.copyWith(
        machines: machines,
        status: LoadingStatus.success,
      );

      // Apply filters to the newly loaded data
      _applyFilters();
    } catch (e) {
      state = state.copyWith(
        status: LoadingStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> refresh() async {
    if (_currentTeamId == null) return;
    await loadMachines(_currentTeamId!);
  }

  // ===== WEB FILTER HANDLERS =====

  void onStatusFilterChanged(MachineStatusFilter filter) {
    state = state.copyWith(
      selectedStatusFilter: filter,
      currentPage: 1,
    );
    _applyFilters();
  }

  void onDateFilterChanged(DateFilterRange dateFilter) {
    state = state.copyWith(
      dateFilter: dateFilter,
      currentPage: 1,
    );
    _applyFilters();
  }

  void clearDateFilter() {
    state = state.copyWith(
      dateFilter: const DateFilterRange(type: DateFilterType.none),
      currentPage: 1,
    );
    _applyFilters();
  }

  void onSearchChanged(String query) {
    state = state.copyWith(
      searchQuery: query,
      currentPage: 1,
      // MOBILE: Reset display limit
      displayLimit: _pageSize,
    );
    _applyFilters();
  }

  void clearSearch() {
    state = state.copyWith(
      searchQuery: '',
      currentPage: 1,
      // MOBILE: Reset display limit
      displayLimit: _pageSize,
    );
    _applyFilters();
  }

  // ===== WEB SORTING HANDLERS =====

  void onSort(String column) {
    final isAscending = state.sortColumn == column ? !state.sortAscending : true;
    
    state = state.copyWith(
      sortColumn: column,
      sortAscending: isAscending,
    );
    
    _applyFilters();
  }

  // ===== WEB PAGINATION HANDLERS =====

  void onPageChanged(int page) {
    state = state.copyWith(currentPage: page);
  }

  void onItemsPerPageChanged(int itemsPerPage) {
    state = state.copyWith(
      itemsPerPage: itemsPerPage,
      currentPage: 1,
    );
  }

  // ===== FILTERING LOGIC =====

  /// Apply all filters using the filter service
  void _applyFilters() {
    final result = _filterService.applyAllFilters(
      machines: state.machines,
      selectedStatusFilter: state.selectedStatusFilter,
      dateFilter: state.dateFilter,
      searchQuery: state.searchQuery,
      sortColumn: state.sortColumn,
      sortAscending: state.sortAscending,
    );

    state = state.copyWith(
      filteredMachines: result.filteredMachines,
    );
  }

  // ===== MACHINE OPERATIONS =====

  Future<void> addMachine({
    required String teamId,
    required String machineName,
    required String machineId,
    required List<String> assignedUserIds,
  }) async {
    try {
      final exists = await _aggregator.checkMachineExists(machineId);
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

      await _aggregator.createMachine(request);
      await Future.delayed(const Duration(milliseconds: 1000));
      await refresh();
    } catch (e) {
      state = state.copyWith(
        status: LoadingStatus.error,
        errorMessage: 'Failed to add machine: $e',
      );
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

      await _aggregator.updateMachine(request);
      await Future.delayed(const Duration(milliseconds: 1000));
      await refresh();
    } catch (e) {
      state = state.copyWith(
        status: LoadingStatus.error,
        errorMessage: 'Failed to update machine: $e',
      );
      rethrow;
    }
  }

  Future<void> archiveMachine(String teamId, String machineId) async {
    try {
      await _aggregator.archiveMachine(machineId);
      await Future.delayed(const Duration(milliseconds: 300));
      await refresh();
    } catch (e) {
      state = state.copyWith(
        status: LoadingStatus.error,
        errorMessage: 'Failed to archive machine: $e',
      );
      rethrow;
    }
  }

  Future<void> restoreMachine(String teamId, String machineId) async {
    try {
      await _aggregator.restoreMachine(machineId);
      await Future.delayed(const Duration(milliseconds: 300));
      await refresh();
    } catch (e) {
      state = state.copyWith(
        status: LoadingStatus.error,
        errorMessage: 'Failed to restore machine: $e',
      );
      rethrow;
    }
  }

  Future<bool> machineExists(String machineId) async {
    try {
      return await _aggregator.checkMachineExists(machineId);
    } catch (e) {
      debugPrint('Error checking machine existence: $e');
      return false;
    }
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  // ========================================
  // MOBILE ONLY - Will be removed after mobile refactor
  // ========================================

  void setFilterTab(MachineFilterTab tab) {
    state = state.copyWith(
      selectedTab: tab,
      searchQuery: '',
      displayLimit: _pageSize,
      currentPage: 1,
    );
  }

  void loadMore() {
    state = state.copyWith(displayLimit: state.displayLimit + _pageSize);
  }

  // ========================================
}