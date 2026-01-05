import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../data/models/machine_model.dart';
import '../../../data/repositories/machine_repository/machine_repository.dart';
import '../../../data/providers/machine_providers.dart';

part 'operator_machine_notifier.g.dart';

// Update this to match the enum from the widget
enum DateFilter {
  none,      // Changed from 'all' to 'none'
  today,
  last3Days,
  last7Days,
  last30Days,
  custom,
}

class OperatorMachineState {
  final List<MachineModel> machines;
  final bool isLoading;
  final String? errorMessage;
  final String searchQuery;
  final int currentPage;
  final int itemsPerPage;
  final int baseItemsPerPage; // Base page size for pagination
  final DateFilter dateFilter;
  final DateTime? customStartDate;
  final DateTime? customEndDate;

  const OperatorMachineState({
    this.machines = const [],
    this.isLoading = false,
    this.errorMessage,
    this.searchQuery = '',
    this.currentPage = 1,
    this.itemsPerPage = 10,
    this.baseItemsPerPage = 10,
    this.dateFilter = DateFilter.none, // Changed default to 'none'
    this.customStartDate,
    this.customEndDate,
  });

  OperatorMachineState copyWith({
    List<MachineModel>? machines,
    bool? isLoading,
    String? errorMessage,
    String? searchQuery,
    int? currentPage,
    int? itemsPerPage,
    int? baseItemsPerPage,
    DateFilter? dateFilter,
    DateTime? customStartDate,
    DateTime? customEndDate,
  }) {
    return OperatorMachineState(
      machines: machines ?? this.machines,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      searchQuery: searchQuery ?? this.searchQuery,
      currentPage: currentPage ?? this.currentPage,
      itemsPerPage: itemsPerPage ?? this.itemsPerPage,
      baseItemsPerPage: baseItemsPerPage ?? this.baseItemsPerPage,
      dateFilter: dateFilter ?? this.dateFilter,
      customStartDate: customStartDate ?? this.customStartDate,
      customEndDate: customEndDate ?? this.customEndDate,
    );
  }

  List<MachineModel> get filteredMachines {
    var filtered = machines;

    // Apply date filter (skip if 'none' is selected)
    if (dateFilter != DateFilter.none) { // Changed from 'all' to 'none'
      final now = DateTime.now();
      DateTime? startDate;
      DateTime? endDate = now;

      switch (dateFilter) {
        case DateFilter.today:
          startDate = DateTime(now.year, now.month, now.day);
          break;
        case DateFilter.last3Days:
          startDate = now.subtract(const Duration(days: 3));
          break;
        case DateFilter.last7Days:
          startDate = now.subtract(const Duration(days: 7));
          break;
        case DateFilter.last30Days:
          startDate = now.subtract(const Duration(days: 30));
          break;
        case DateFilter.custom:
          startDate = customStartDate;
          endDate = customEndDate ?? now;
          break;
        case DateFilter.none: // Added none case
          break;
      }

      if (startDate != null) {
        filtered = filtered.where((m) {
          final machineDate = m.dateCreated;
          return machineDate.isAfter(startDate!.subtract(const Duration(days: 1))) && 
                 (endDate == null || machineDate.isBefore(endDate.add(const Duration(days: 1))));
        }).toList();
      }
    }

    // Apply search filter
    if (searchQuery.isEmpty) {
      return filtered;
    }

    return filtered.where((m) {
      final query = searchQuery.toLowerCase();
      return m.machineName.toLowerCase().contains(query) ||
          m.machineId.toLowerCase().contains(query);
    }).toList();
  }

  // Calculate total pages based on base page size (not the expanded itemsPerPage)
  int get totalPages {
    if (filteredMachines.isEmpty) return 0;
    return (filteredMachines.length / baseItemsPerPage).ceil();
  }

  // Get the slice of machines for current page
  List<MachineModel> get currentPageMachines {
    final startIndex = (currentPage - 1) * baseItemsPerPage;
    final endIndex = currentPage * baseItemsPerPage;
    
    if (startIndex >= filteredMachines.length) {
      return [];
    }
    
    return filteredMachines.sublist(
      startIndex,
      endIndex > filteredMachines.length ? filteredMachines.length : endIndex,
    );
  }

  // Display only up to itemsPerPage from current page's machines
  List<MachineModel> get displayedMachines {
    // Calculate how many items to show from the current page
    final displayCount = itemsPerPage.clamp(0, currentPageMachines.length);
    return currentPageMachines.take(displayCount).toList();
  }

  // Check if there are more items to load on the current page
  bool get hasMoreToLoad {
    return displayedMachines.length < currentPageMachines.length;
  }

  // Count of remaining items on current page
  int get remainingCount {
    return currentPageMachines.length - displayedMachines.length;
  }

  int get activeMachinesCount =>
      machines.where((m) => !m.isArchived).length;

  int get archivedMachinesCount =>
      machines.where((m) => m.isArchived).length;
}

@riverpod
class OperatorMachineNotifier extends _$OperatorMachineNotifier {
  static const int _basePageSize = 10;
  static const int _loadMoreIncrement = 10;
  
  MachineRepository get _repository => ref.read(machineRepositoryProvider);

  @override
  OperatorMachineState build() {
    return const OperatorMachineState();
  }

  Future<void> initialize(String teamId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final machines = await _repository.getMachinesByTeam(teamId)
          .timeout(const Duration(seconds: 10));
      state = state.copyWith(
        machines: machines,
        isLoading: false,
        currentPage: 1,
        itemsPerPage: _basePageSize,
        baseItemsPerPage: _basePageSize,
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Failed to load: ${e.toString().replaceAll('Exception:', '').trim()}',
        isLoading: false,
      );
    }
  }

  Future<void> refresh(String teamId) async {
    try {
      final machines = await _repository.getMachinesByTeam(teamId)
          .timeout(const Duration(seconds: 10));
      state = state.copyWith(machines: machines);
    } catch (e) {
      state = state.copyWith(errorMessage: 'Failed to refresh: ${e.toString().replaceAll('Exception:', '').trim()}');
    }
  }

  void setSearchQuery(String query) {
    state = state.copyWith(
      searchQuery: query,
      currentPage: 1,
      itemsPerPage: state.baseItemsPerPage, // Reset to base page size
    );
  }

  void clearSearch() {
    state = state.copyWith(
      searchQuery: '',
      currentPage: 1,
      itemsPerPage: state.baseItemsPerPage, // Reset to base page size
    );
  }

  void setDateFilter(DateFilter filter) {
    state = state.copyWith(
      dateFilter: filter,
      currentPage: 1, // Reset to first page when changing filter
      itemsPerPage: state.baseItemsPerPage,
    );
  }

  void setCustomDateRange(DateTime? startDate, DateTime? endDate) {
    state = state.copyWith(
      dateFilter: DateFilter.custom,
      customStartDate: startDate,
      customEndDate: endDate,
      currentPage: 1,
      itemsPerPage: state.baseItemsPerPage,
    );
  }

  // Load more items on the current page
  void loadMore() {
    if (state.hasMoreToLoad) {
      state = state.copyWith(
        itemsPerPage: state.itemsPerPage + _loadMoreIncrement,
      );
    }
  }

  // Set the page size from the dropdown selector
  void setItemsPerPage(int count) {
    state = state.copyWith(
      itemsPerPage: count,
      baseItemsPerPage: count,
      currentPage: 1, // Reset to first page when changing page size
    );
  }

  void goToNextPage() {
    if (state.currentPage < state.totalPages) {
      state = state.copyWith(
        currentPage: state.currentPage + 1,
        itemsPerPage: state.baseItemsPerPage, // Reset to base page size on page change
      );
    }
  }

  void goToPreviousPage() {
    if (state.currentPage > 1) {
      state = state.copyWith(
        currentPage: state.currentPage - 1,
        itemsPerPage: state.baseItemsPerPage, // Reset to base page size on page change
      );
    }
  }

  void goToPage(int page) {
    if (page >= 1 && page <= state.totalPages) {
      state = state.copyWith(
        currentPage: page,
        itemsPerPage: state.baseItemsPerPage, // Reset to base page size on page change
      );
    }
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}