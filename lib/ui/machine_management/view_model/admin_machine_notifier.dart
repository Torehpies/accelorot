import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../data/models/machine_model.dart';
import '../../../data/repositories/machine_repository/machine_repository.dart';
import '../../../data/providers/machine_providers.dart';

part 'admin_machine_notifier.g.dart';

// State class remains the same
enum MachineFilterTab {
  all,
  active,
  inactive,
  archived,
}

class AdminMachineState {
  final List<MachineModel> machines;
  final MachineFilterTab selectedTab;
  final bool isLoading;
  final String? errorMessage;
  final String searchQuery;
  final int displayLimit;

  const AdminMachineState({
    this.machines = const [],
    this.selectedTab = MachineFilterTab.all,
    this.isLoading = false,
    this.errorMessage,
    this.searchQuery = '',
    this.displayLimit = 5,
  });

  AdminMachineState copyWith({
    List<MachineModel>? machines,
    MachineFilterTab? selectedTab,
    bool? isLoading,
    String? errorMessage,
    String? searchQuery,
    int? displayLimit,
  }) {
    return AdminMachineState(
      machines: machines ?? this.machines,
      selectedTab: selectedTab ?? this.selectedTab,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      searchQuery: searchQuery ?? this.searchQuery,
      displayLimit: displayLimit ?? this.displayLimit,
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
      case MachineFilterTab.inactive:
        filtered = machines
            .where((m) => !m.isArchived && m.status == MachineStatus.inactive)
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

    return filtered;
  }

  List<MachineModel> get displayedMachines {
    return filteredMachines.take(displayLimit).toList();
  }

  bool get hasMoreToLoad {
    return displayedMachines.length < filteredMachines.length;
  }

  int get remainingCount {
    return filteredMachines.length - displayedMachines.length;
  }
}

// Use Notifier instead of StateNotifier
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
      final machines = await _repository.getMachinesByTeam(teamId);
      state = state.copyWith(machines: machines, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Failed to load machines: ${e.toString()}',
        isLoading: false,
      );
    }
  }

  Future<void> refresh(String teamId) async {
    try {
      final machines = await _repository.getMachinesByTeam(teamId);
      state = state.copyWith(machines: machines);
    } catch (e) {
      state = state.copyWith(errorMessage: 'Failed to refresh: $e');
    }
  }

  void setFilterTab(MachineFilterTab tab) {
    state = state.copyWith(
      selectedTab: tab,
      searchQuery: '',
      displayLimit: _pageSize,
    );
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query, displayLimit: _pageSize);
  }

  void clearSearch() {
    state = state.copyWith(searchQuery: '', displayLimit: _pageSize);
  }

  void loadMore() {
    state = state.copyWith(displayLimit: state.displayLimit + _pageSize);
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