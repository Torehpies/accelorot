// lib/ui/operator_dashboard/models/operator_dashboard_state.dart

import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../data/models/machine_model.dart';
import '../../activity_logs/models/activity_common.dart';
import '../../machine_management/services/machine_filter_service.dart';

part 'operator_dashboard_state.freezed.dart';

/// State for the operator dashboard (mobile machine list view)
@freezed
abstract class OperatorDashboardState with _$OperatorDashboardState {
  const factory OperatorDashboardState({
    // Filters
    @Default(MachineStatusFilter.active) MachineStatusFilter selectedStatusFilter,
    @Default(DateFilterRange(type: DateFilterType.none)) DateFilterRange dateFilter,
    @Default('') String searchQuery,

    // Sorting (optional for mobile)
    @Default('date') String selectedSort,

    // Data
    @Default([]) List<MachineModel> machines,

    // Pagination (load-more pattern)
    @Default(5) int displayLimit,

    // UI state
    @Default(LoadingStatus.initial) LoadingStatus status,
    String? errorMessage,
  }) = _OperatorDashboardState;

  const OperatorDashboardState._();

  // ===== COMPUTED PROPERTIES =====

  bool get isLoading => status == LoadingStatus.loading;
  bool get hasError => status == LoadingStatus.error;

  /// Get filtered machines using shared filter service
  List<MachineModel> get filteredMachines {
    final filterService = MachineFilterService();

    // Strictly filter for active and non-archived machines first
    final activeMachines = machines.where((m) => 
      m.status == MachineStatus.active && !m.isArchived
    ).toList();

    final result = filterService.applyAllFilters(
      machines: activeMachines,
      selectedStatusFilter: MachineStatusFilter.active, // Force active filter
      dateFilter: dateFilter,
      searchQuery: searchQuery,
      sortColumn: selectedSort,
      sortAscending: false, // Mobile sorts newest first by default
    );

    return result.filteredMachines;
  }

  /// Get displayed machines (with load-more limit applied)
  List<MachineModel> get displayedMachines {
    if (filteredMachines.length <= displayLimit) {
      return filteredMachines;
    }
    return filteredMachines.sublist(0, displayLimit);
  }

  /// Check if there are more machines to load
  bool get hasMoreToLoad => filteredMachines.length > displayLimit;

  /// Get count of remaining machines
  int get remainingCount => filteredMachines.length - displayLimit;

  /// Check if has any active filters
  bool get hasActiveFilters {
    return selectedStatusFilter != MachineStatusFilter.all ||
        dateFilter.isActive ||
        searchQuery.isNotEmpty;
  }
}
