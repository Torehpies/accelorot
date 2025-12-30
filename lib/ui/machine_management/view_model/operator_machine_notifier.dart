import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../data/models/machine_model.dart';
import '../../../data/repositories/machine_repository/machine_repository.dart';
import '../../../data/providers/machine_providers.dart';


part 'operator_machine_notifier.g.dart';

class OperatorMachineState {
  final List<MachineModel> machines;
  final bool isLoading;
  final String? errorMessage;
  final String searchQuery;
  final int currentPage;
  final int itemsPerPage;
  final int baseItemsPerPage; // Base page size for pagination

  const OperatorMachineState({
    this.machines = const [],
    this.isLoading = false,
    this.errorMessage,
    this.searchQuery = '',
    this.currentPage = 1,
    this.itemsPerPage = 10,
    this.baseItemsPerPage = 10,
  });

  OperatorMachineState copyWith({
    List<MachineModel>? machines,
    bool? isLoading,
    String? errorMessage,
    String? searchQuery,
    int? currentPage,
    int? itemsPerPage,
    int? baseItemsPerPage,
  }) {
    return OperatorMachineState(
      machines: machines ?? this.machines,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      searchQuery: searchQuery ?? this.searchQuery,
      currentPage: currentPage ?? this.currentPage,
      itemsPerPage: itemsPerPage ?? this.itemsPerPage,
      baseItemsPerPage: baseItemsPerPage ?? this.baseItemsPerPage,
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
    return currentPageMachines.take(itemsPerPage - ((currentPage - 1) * baseItemsPerPage)).toList();
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
  static const int _basePageSize = 9;
  static const int _loadMoreIncrement = 9;
  
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
      itemsPerPage: _basePageSize, // Reset to base page size
    );
  }

  void clearSearch() {
    state = state.copyWith(
      searchQuery: '',
      currentPage: 1,
      itemsPerPage: _basePageSize, // Reset to base page size
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

  void goToNextPage() {
    if (state.currentPage < state.totalPages) {
      state = state.copyWith(
        currentPage: state.currentPage + 1,
        itemsPerPage: _basePageSize, // Reset to base page size on page change
      );
    }
  }

  void goToPreviousPage() {
    if (state.currentPage > 1) {
      state = state.copyWith(
        currentPage: state.currentPage - 1,
        itemsPerPage: _basePageSize, // Reset to base page size on page change
      );
    }
  }

  void goToPage(int page) {
    if (page >= 1 && page <= state.totalPages) {
      state = state.copyWith(
        currentPage: page,
        itemsPerPage: _basePageSize, // Reset to base page size on page change
      );
    }
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}