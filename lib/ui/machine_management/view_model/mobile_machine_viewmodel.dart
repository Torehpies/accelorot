// lib/ui/machine_management/view_model/mobile_machine_viewmodel.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../data/models/machine_model.dart';
import '../../../data/providers/machine_providers.dart';
import '../services/machine_aggregator_service.dart';
import '../models/mobile_machine_state.dart';
import '../../activity_logs/models/activity_common.dart';

part 'mobile_machine_viewmodel.g.dart';

// ===== AGGREGATOR SERVICE PROVIDER =====
@riverpod
MachineAggregatorService mobileMachineAggregatorService(Ref ref) {
  final repository = ref.watch(machineRepositoryProvider);
  return MachineAggregatorService(machineRepo: repository);
}

// ===== MOBILE MACHINE VIEW MODEL =====
@riverpod
class MobileMachineViewModel extends _$MobileMachineViewModel {
  static const int _loadMoreIncrement = 5;
  
  late final MachineAggregatorService _aggregator;

  @override
  MobileMachineState build() {
    _aggregator = ref.read(mobileMachineAggregatorServiceProvider);
    return const MobileMachineState();
  }

  // ===== INITIALIZATION =====

  Future<void> initialize(String teamId) async {
    state = state.copyWith(status: LoadingStatus.loading, errorMessage: null);

    try {
      final machines = await _aggregator.getMachines(teamId)
          .timeout(const Duration(seconds: 10));

      if (!ref.mounted) return;
      
      state = state.copyWith(
        machines: machines,
        status: LoadingStatus.success,
      );
    } catch (e) {
      if (!ref.mounted) return;
      state = state.copyWith(
        status: LoadingStatus.error,
        errorMessage: 'Failed to load: ${e.toString().replaceAll('Exception:', '').trim()}',
      );
    }
  }

  Future<void> refresh(String teamId) async {
    try {
      final machines = await _aggregator.getMachines(teamId)
          .timeout(const Duration(seconds: 10));
      
      state = state.copyWith(machines: machines);
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Failed to refresh: ${e.toString().replaceAll('Exception:', '').trim()}',
      );
    }
  }

  // ===== MOBILE-SPECIFIC: STATUS FILTERING =====

  void setStatusFilter(MachineStatusFilter filter) {
    HapticFeedback.selectionClick();
    state = state.copyWith(
      selectedStatusFilter: filter,
      searchQuery: '', // Clear search when switching status
      displayLimit: _loadMoreIncrement, // Reset to initial limit
    );
  }

  // ===== MOBILE-SPECIFIC: LOAD-MORE PAGINATION =====

  void loadMore() {
    state = state.copyWith(
      displayLimit: state.displayLimit + _loadMoreIncrement,
    );
  }

  void resetDisplayLimit() {
    state = state.copyWith(displayLimit: _loadMoreIncrement);
  }

  // ===== SHARED: DATE FILTERING =====

  void setDateFilter(DateFilterRange dateFilter) {
    HapticFeedback.selectionClick();
    state = state.copyWith(
      dateFilter: dateFilter,
      displayLimit: _loadMoreIncrement, // Reset pagination
    );
  }

  void clearDateFilter() {
    state = state.copyWith(
      dateFilter: const DateFilterRange(type: DateFilterType.none),
      displayLimit: _loadMoreIncrement,
    );
  }

  // ===== SHARED: SEARCH FILTERING =====

  void setSearchQuery(String query) {
    state = state.copyWith(
      searchQuery: query,
      displayLimit: _loadMoreIncrement, // Reset pagination on search
    );
  }

  void clearSearch() {
    state = state.copyWith(
      searchQuery: '',
      displayLimit: _loadMoreIncrement,
    );
  }

  // ===== SHARED: SORTING =====

  void setSort(String sortBy) {
    state = state.copyWith(selectedSort: sortBy);
  }

  // ===== CLEAR ALL FILTERS =====

  void clearAllFilters() {
    state = state.copyWith(
      selectedStatusFilter: MachineStatusFilter.all,
      dateFilter: const DateFilterRange(type: DateFilterType.none),
      searchQuery: '',
      displayLimit: _loadMoreIncrement,
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
      await refresh(teamId);
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
      await refresh(teamId);
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
      await refresh(teamId);
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
      await refresh(teamId);
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
}