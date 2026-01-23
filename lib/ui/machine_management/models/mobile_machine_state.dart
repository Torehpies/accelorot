// lib/ui/machine_management/models/mobile_machine_state.dart

import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../data/models/machine_model.dart';
import '../../activity_logs/models/activity_common.dart';
import '../services/machine_filter_service.dart';

part 'mobile_machine_state.freezed.dart';

/// State for mobile machine management
@freezed
abstract class MobileMachineState with _$MobileMachineState {
  const factory MobileMachineState({
    // Filters - now using MachineStatusFilter instead of MachineFilterTab
    @Default(MachineStatusFilter.all) MachineStatusFilter selectedStatusFilter,
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
  }) = _MobileMachineState;

  const MobileMachineState._();

  // ===== COMPUTED PROPERTIES =====

  bool get isLoading => status == LoadingStatus.loading;
  bool get hasError => status == LoadingStatus.error;

  /// Get filtered machines using shared filter service
  List<MachineModel> get filteredMachines {
    final filterService = MachineFilterService();
    
    final result = filterService.applyAllFilters(
      machines: machines,
      selectedStatusFilter: selectedStatusFilter,
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