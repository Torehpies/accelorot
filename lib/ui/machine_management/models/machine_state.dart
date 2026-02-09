// lib/ui/machine_management/models/machine_state.dart

import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../data/models/machine_model.dart';
import '../../activity_logs/models/activity_common.dart';

part 'machine_state.freezed.dart';

/// State for machine management (WEB ONLY)
@freezed
abstract class MachineState with _$MachineState {
  const factory MachineState({
    // Filters
    @Default(MachineStatusFilter.all) MachineStatusFilter selectedStatusFilter,
    @Default(DateFilterRange(type: DateFilterType.none))
    DateFilterRange dateFilter,
    @Default('') String searchQuery,

    // Sorting
    String? sortColumn,
    @Default(true) bool sortAscending,

    // Data
    @Default([]) List<MachineModel> machines,
    @Default([]) List<MachineModel> filteredMachines,

    // Pagination
    @Default(1) int currentPage,
    @Default(10) int itemsPerPage,

    // UI state
    @Default(LoadingStatus.initial) LoadingStatus status,
    String? errorMessage,
    @Default(true) bool isLoggedIn,
  }) = _MachineState;

  const MachineState._();

  // ===== COMPUTED PROPERTIES =====

  bool get isLoading => status == LoadingStatus.loading;
  bool get hasError => status == LoadingStatus.error;
  bool get isEmpty =>
      filteredMachines.isEmpty && status == LoadingStatus.success;

  /// Get paginated machines for current page
  List<MachineModel> get paginatedMachines {
    final startIndex = (currentPage - 1) * itemsPerPage;
    final endIndex = startIndex + itemsPerPage;

    if (startIndex >= filteredMachines.length) {
      return [];
    }

    return filteredMachines.sublist(
      startIndex,
      endIndex > filteredMachines.length ? filteredMachines.length : endIndex,
    );
  }

  /// Total number of pages
  int get totalPages {
    if (filteredMachines.isEmpty) return 1;
    return (filteredMachines.length / itemsPerPage).ceil();
  }

  /// Check if has any active filters
  bool get hasActiveFilters {
    return selectedStatusFilter != MachineStatusFilter.all ||
        dateFilter.isActive ||
        searchQuery.isNotEmpty;
  }
}
