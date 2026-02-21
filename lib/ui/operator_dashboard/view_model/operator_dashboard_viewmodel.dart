// lib/ui/operator_dashboard/view_model/operator_dashboard_viewmodel.dart

import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../data/models/machine_model.dart';
import '../../../data/providers/machine_providers.dart';
import '../../machine_management/services/machine_aggregator_service.dart';
import '../models/operator_dashboard_state.dart';
import '../../activity_logs/models/activity_common.dart';

part 'operator_dashboard_viewmodel.g.dart';

// ===== AGGREGATOR SERVICE PROVIDER =====
@riverpod
MachineAggregatorService operatorDashboardAggregatorService(Ref ref) {
  final repository = ref.watch(machineRepositoryProvider);
  return MachineAggregatorService(machineRepo: repository);
}

// ===== OPERATOR DASHBOARD VIEW MODEL =====
@riverpod
class OperatorDashboardViewModel extends _$OperatorDashboardViewModel {
  static const int _loadMoreIncrement = 5;

  late final MachineAggregatorService _aggregator;

  @override
  OperatorDashboardState build() {
    _aggregator = ref.read(operatorDashboardAggregatorServiceProvider);
    return const OperatorDashboardState();
  }

  // ===== INITIALIZATION =====

  Future<void> initialize(String teamId) async {
    state = state.copyWith(status: LoadingStatus.loading, errorMessage: null);

    try {
      final machines = await _aggregator
          .getMachines(teamId)
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
        errorMessage:
            'Failed to load: ${e.toString().replaceAll('Exception:', '').trim()}',
      );
    }
  }

  Future<void> refresh(String teamId) async {
    try {
      final machines = await _aggregator
          .getMachines(teamId)
          .timeout(const Duration(seconds: 10));

      state = state.copyWith(machines: machines);
    } catch (e) {
      state = state.copyWith(
        errorMessage:
            'Failed to refresh: ${e.toString().replaceAll('Exception:', '').trim()}',
      );
    }
  }

  // ===== STATUS FILTERING =====

  void setStatusFilter(MachineStatusFilter filter) {
    HapticFeedback.selectionClick();
    state = state.copyWith(
      selectedStatusFilter: filter,
      searchQuery: '', // Clear search when switching status
      displayLimit: _loadMoreIncrement, // Reset to initial limit
    );
  }

  // ===== LOAD-MORE PAGINATION =====

  void loadMore() {
    state = state.copyWith(
      displayLimit: state.displayLimit + _loadMoreIncrement,
    );
  }

  void resetDisplayLimit() {
    state = state.copyWith(displayLimit: _loadMoreIncrement);
  }

  // ===== DATE FILTERING =====

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

  // ===== SEARCH FILTERING =====

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

  // ===== SORTING =====

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

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}
