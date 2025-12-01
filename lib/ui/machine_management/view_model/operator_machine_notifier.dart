//import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../data/models/machine_model.dart';
import '../../../data/repositories/machine_repository.dart';
import '../../../data/providers/machine_providers.dart';

part 'operator_machine_notifier.g.dart';

// State class remains the same
class OperatorMachineState {
  final List<MachineModel> machines;
  final bool isLoading;
  final String? errorMessage;
  final String searchQuery;
  final int displayLimit;

  const OperatorMachineState({
    this.machines = const [],
    this.isLoading = false,
    this.errorMessage,
    this.searchQuery = '',
    this.displayLimit = 10,
  });

  OperatorMachineState copyWith({
    List<MachineModel>? machines,
    bool? isLoading,
    String? errorMessage,
    String? searchQuery,
    int? displayLimit,
  }) {
    return OperatorMachineState(
      machines: machines ?? this.machines,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      searchQuery: searchQuery ?? this.searchQuery,
      displayLimit: displayLimit ?? this.displayLimit,
    );
  }

  List<MachineModel> get filteredMachines {
    if (searchQuery.isEmpty) {
      return machines;
    }

    return machines.where((m) {
      final query = searchQuery.toLowerCase();
      return m.machineName.toLowerCase().contains(query) ||
          m.machineId.toLowerCase().contains(query);
    }).toList();
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

  int get activeMachinesCount =>
      machines.where((m) => !m.isArchived).length;

  int get archivedMachinesCount =>
      machines.where((m) => m.isArchived).length;
}

// Use Notifier instead of StateNotifier
@riverpod
class OperatorMachineNotifier extends _$OperatorMachineNotifier {
  static const int _pageSize = 10;
  
  MachineRepository get _repository => ref.read(machineRepositoryProvider);

  @override
  OperatorMachineState build() {
    return const OperatorMachineState();
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

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query, displayLimit: _pageSize);
  }

  void clearSearch() {
    state = state.copyWith(searchQuery: '', displayLimit: _pageSize);
  }

  void loadMore() {
    state = state.copyWith(displayLimit: state.displayLimit + _pageSize);
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}