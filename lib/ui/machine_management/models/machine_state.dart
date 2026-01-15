// lib/ui/machine_management/models/machine_state.dart

import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../data/models/machine_model.dart';
import '../../activity_logs/models/activity_common.dart';

part 'machine_state.freezed.dart';

// ========================================
// MOBILE ONLY - Will be removed after mobile refactor
// ========================================
enum MachineFilterTab {
  all,
  active,
  suspended,
  archived,
}
// ========================================

/// State for machine management
@freezed
abstract class MachineState with _$MachineState {
  const factory MachineState({
    // ========================================
    // MOBILE ONLY - Will be removed after mobile refactor
    // ========================================
    @Default(MachineFilterTab.all) MachineFilterTab selectedTab,
    @Default(5) int displayLimit,
    // ========================================

    // WEB Filters
    @Default(MachineStatusFilter.all) MachineStatusFilter selectedStatusFilter,
    @Default(DateFilterRange(type: DateFilterType.none)) DateFilterRange dateFilter,
    @Default('') String searchQuery,

    // Sorting
    String? sortColumn,
    @Default(true) bool sortAscending,

    // Data
    @Default([]) List<MachineModel> machines,
    @Default([]) List<MachineModel> filteredMachines,

    // Pagination (WEB)
    @Default(1) int currentPage,
    @Default(10) int itemsPerPage,

    // UI state
    @Default(LoadingStatus.initial) LoadingStatus status,
    String? errorMessage,
    @Default(true) bool isLoggedIn,
  }) = _MachineState;

  const MachineState._();

  // ===== WEB COMPUTED PROPERTIES =====

  bool get isLoading => status == LoadingStatus.loading;
  bool get hasError => status == LoadingStatus.error;
  bool get isEmpty => filteredMachines.isEmpty && status == LoadingStatus.success;

  /// Get paginated machines for current page (WEB)
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

  /// Total number of pages (WEB)
  int get totalPages {
    if (filteredMachines.isEmpty) return 1;
    return (filteredMachines.length / itemsPerPage).ceil();
  }

  /// Check if has any active filters (WEB)
  bool get hasActiveFilters {
    return selectedStatusFilter != MachineStatusFilter.all ||
        dateFilter.isActive ||
        searchQuery.isNotEmpty;
  }

  // ========================================
  // MOBILE ONLY - Will be removed after mobile refactor
  // ========================================
  
  /// MOBILE: Filtered machines by tab
  List<MachineModel> get filteredMachinesByTab {
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

    // Apply sorting if set
    if (sortColumn != null) {
      filtered = _sortMachines(filtered, sortColumn!, sortAscending);
    }

    return filtered;
  }

  /// MOBILE: Load-more pattern
  List<MachineModel> get displayedMachines {
    return filteredMachinesByTab.take(displayLimit).toList();
  }

  bool get hasMoreToLoad {
    return displayedMachines.length < filteredMachinesByTab.length;
  }

  int get remainingCount {
    return filteredMachinesByTab.length - displayedMachines.length;
  }

  /// Helper: Sort machines
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
  // ========================================
}