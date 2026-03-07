// lib/ui/operator_dashboard/models/operator_dashboard_state.dart

import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../data/models/machine_model.dart';
import '../../activity_logs/models/activity_common.dart';
import '../../machine_management/services/machine_filter_service.dart';

part 'operator_dashboard_state.freezed.dart';

/// Filter enum for operator dashboard drum status
enum DrumStatusFilter {
  all,
  alert,
  running,
  rest,
  empty;

  String get displayName {
    switch (this) {
      case DrumStatusFilter.all:
        return 'All Machines';
      case DrumStatusFilter.alert:
        return 'Alert';
      case DrumStatusFilter.running:
        return 'Running';
      case DrumStatusFilter.rest:
        return 'Rest';
      case DrumStatusFilter.empty:
        return 'Empty';
    }
  }
}

/// State for the operator dashboard (mobile machine list view)
@freezed
abstract class OperatorDashboardState with _$OperatorDashboardState {
  const factory OperatorDashboardState({
    // Filters
    @Default(DrumStatusFilter.all) DrumStatusFilter selectedDrumFilter,
    @Default(DateFilterRange(type: DateFilterType.none)) DateFilterRange dateFilter,
    @Default('') String searchQuery,

    // Sorting (optional for mobile)
    @Default('date') String selectedSort,

    // Data
    @Default([]) List<MachineModel> machines,

    // UI state

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

    // 1. Base filter: Strictly active and non-archived machines
    final activeMachines = machines.where((m) => 
      m.status == MachineStatus.active && !m.isArchived
    ).toList();

    // 2. Apply text and date search
    final result = filterService.applyAllFilters(
      machines: activeMachines,
      selectedStatusFilter: MachineStatusFilter.active, // Always active
      dateFilter: dateFilter,
      searchQuery: searchQuery,
      sortColumn: selectedSort,
      sortAscending: false,
    );
    
    // 3. Apply custom Drum Status filter
    // Note: Alert state is dynamic/async, so filtering by 'Alert' relies on 
    // basic heuristics here if we don't have synchronous readings. 
    // Ideally, the View will handle showing Alert vs Running. 
    // For now, if 'Alert' is selected, we show machines with active batches to let the UI resolve it,
    // or we could filter purely synchronously:
    var finalMachines = result.filteredMachines;
    switch (selectedDrumFilter) {
      case DrumStatusFilter.all:
        break; // no extra filtering
      case DrumStatusFilter.empty:
        finalMachines = finalMachines.where((m) => m.currentBatchId == null).toList();
        break;
      case DrumStatusFilter.running:
        finalMachines = finalMachines.where((m) => m.currentBatchId != null && m.drumActive).toList();
        break;
      case DrumStatusFilter.rest:
        finalMachines = finalMachines.where((m) => m.currentBatchId != null && !m.drumActive).toList();
        break;
      case DrumStatusFilter.alert:
        // Since Alert is calculated asynchronously in the UI based on live sensor streams,
        // we conservatively return all machines with active batches to the UI, 
        // OR we'd need to sync readings in the state. 
        // To accurately filter without fetching streams for all 100 machines, 
        // we'll pass machines with batches down and let the custom filter widget handle it later if needed.
        // For strict offline filtering, we just check if it has a batch for now.
        finalMachines = finalMachines.where((m) => m.currentBatchId != null).toList();
        break;
    }

    return finalMachines;
  }

  /// Check if has any active filters
  bool get hasActiveFilters {
    return selectedDrumFilter != DrumStatusFilter.all ||
        dateFilter.isActive ||
        searchQuery.isNotEmpty;
  }
}
