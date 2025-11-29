// lib/ui/activity_logs/view_model/base_activity_viewmodel.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_1/data/repositories/activity_repository.dart';
import '../../../data/models/activity_item.dart';
import '../../../data/models/activity_list_state.dart';
import '../models/activity_filter_config.dart';

/// Base ViewModel containing all shared business logic for activity screens
/// Child classes only need to provide configuration and data fetching strategy
abstract class BaseActivityViewModel extends StateNotifier<ActivityListState> {
  final ActivityRepository _repository;
  final ActivityFilterConfig _config;

  BaseActivityViewModel({
    required ActivityRepository repository,
    required ActivityFilterConfig config,
    String? initialFilter,
    String? viewingOperatorId,
    String? focusedMachineId,
  })  : _repository = repository,
        _config = config,
        super(const ActivityListState()) {
    // Update state with initial values
    state = state.copyWith(
      selectedFilter: initialFilter ?? 'All',
      isManualFilter: initialFilter != null && initialFilter != 'All',
      focusedMachineId: focusedMachineId,
    );
    _initialize(viewingOperatorId);
  }

  // ===== ABSTRACT METHODS - Child classes implement these =====

  /// Fetch data from repository
  Future<List<ActivityItem>> fetchData(String? viewingOperatorId);

  // ===== CONFIGURATION GETTERS =====

  String get screenTitle => _config.getTitle(machineId: state.focusedMachineId);
  List<String> get filters => _config.filters;

  // ===== INITIALIZATION =====

  Future<void> _initialize(String? viewingOperatorId) async {
    await _checkLoginAndLoadData(viewingOperatorId);
  }

  Future<void> _checkLoginAndLoadData(String? viewingOperatorId) async {
    state = state.copyWith(
      status: LoadingStatus.loading,
      errorMessage: null,
    );

    try {
      final isLoggedIn = await _repository.isUserLoggedIn();

      if (!isLoggedIn) {
        state = state.copyWith(
          status: LoadingStatus.success,
          isLoggedIn: false,
        );
        return;
      }

      state = state.copyWith(isLoggedIn: true);

      // Upload mock data (if needed for demo)
      await _repository.uploadMockData();

      await loadActivities(viewingOperatorId);
    } catch (e) {
      state = state.copyWith(
        status: LoadingStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  // ===== PUBLIC METHODS =====

  /// Load activities from repository
  Future<void> loadActivities(String? viewingOperatorId) async {
    try {
      List<ActivityItem> activities = await fetchData(viewingOperatorId);

      // Filter by machine if focusedMachineId is set
      if (state.focusedMachineId != null) {
        activities = activities
            .where((item) => item.machineId == state.focusedMachineId)
            .toList();
      }

      state = state.copyWith(
        allActivities: activities,
        status: LoadingStatus.success,
      );

      // Recompute filtered results
      _applyFilters();
    } catch (e) {
      state = state.copyWith(
        status: LoadingStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  /// Reload data (for pull-to-refresh)
  Future<void> refresh(String? viewingOperatorId) async {
    await loadActivities(viewingOperatorId);
  }

  /// Handle filter chip selection
  void onFilterChanged(String filter) {
    state = state.copyWith(
      selectedFilter: filter,
      isManualFilter: true,
    );
    _applyFilters();
  }

  /// Handle search query change
  void onSearchChanged(String query) {
    state = state.copyWith(searchQuery: query.toLowerCase());
    _applyFilters();
  }

  /// Handle search cleared
  void onSearchCleared() {
    state = state.copyWith(searchQuery: '');
    _applyFilters();
  }

  /// Handle date filter change
  void onDateFilterChanged(DateFilterRange dateFilter) {
    state = state.copyWith(dateFilter: dateFilter);
    _applyFilters();
  }

  // ===== PRIVATE FILTERING LOGIC =====

  void _applyFilters() {
    // Step 1: Apply date filter
    final dateFiltered = _applyDateFilter(state.allActivities);

    // Step 2: Apply search filter
    final searchFiltered = _applySearchFilter(dateFiltered);

    // Step 3: Compute auto-highlighted filters
    final highlighted = _computeAutoHighlightedFilters(searchFiltered);

    // Step 4: Apply category filter
    final categoryFiltered = _applyCategoryFilter(searchFiltered);

    state = state.copyWith(
      filteredActivities: categoryFiltered,
      autoHighlightedFilters: highlighted,
    );
  }

  List<ActivityItem> _applyDateFilter(List<ActivityItem> items) {
    if (!state.dateFilter.isActive) return items;

    return items.where((item) {
      return item.timestamp.isAfter(state.dateFilter.startDate!) &&
          item.timestamp.isBefore(state.dateFilter.endDate!);
    }).toList();
  }

  List<ActivityItem> _applySearchFilter(List<ActivityItem> items) {
    if (state.searchQuery.isEmpty) return items;

    return items
        .where((item) => item.matchesSearchQuery(state.searchQuery))
        .toList();
  }

  Set<String> _computeAutoHighlightedFilters(List<ActivityItem> searchResults) {
    if (state.searchQuery.isEmpty) return {};

    final categories = searchResults.map((item) => item.category).toSet();
    return _config.categoryHighlighter(categories, _config.filters);
  }

  List<ActivityItem> _applyCategoryFilter(List<ActivityItem> items) {
    // If manual filter is set and not 'All', apply category filter
    if (state.isManualFilter && state.selectedFilter != 'All') {
      return _config.categoryMapper<ActivityItem>(
        items,
        state.selectedFilter,
        (item) => item.category,
      );
    }

    // If 'All' or no manual filter, show all search results
    return items;
  }
}