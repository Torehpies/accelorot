// lib/ui/activity_logs/view_model/activity_viewmodel.dart

import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/activity_log_item.dart';
import '../models/activity_list_state.dart';
import '../../../data/repositories/activity_repository.dart';
import '../../../data/providers/repository_providers.dart';
import '../models/activity_filter_config.dart';

part 'activity_viewmodel.g.dart';

/// Enum for different activity screen types
enum ActivityScreenType {
  substrates,
  alerts,
  reports,
  cyclesRecom,
  allActivity,
}

@riverpod
class ActivityViewModel extends _$ActivityViewModel {
  
  // ===== CONFIGURATION MAP FOR ALL SCREEN TYPES =====
  
  static final Map<ActivityScreenType, ActivityFilterConfig> _configs = {
    ActivityScreenType.substrates: ActivityFilterConfig(
      screenTitle: 'Substrate Logs',
      filters: const ['All', 'Greens', 'Browns', 'Compost'],
      categoryMapper: CategoryMappers.simple(),
      categoryHighlighter: CategoryHighlighters.simple(['Greens', 'Browns', 'Compost']),
    ),
    
    ActivityScreenType.alerts: ActivityFilterConfig(
      screenTitle: 'Alerts Logs',
      filters: const ['All', 'Temperature', 'Moisture', 'Air Quality'],
      categoryMapper: CategoryMappers.simple(),
      categoryHighlighter: CategoryHighlighters.simple(['Temperature', 'Moisture', 'Oxygen']),
    ),
    
    ActivityScreenType.reports: ActivityFilterConfig(
      screenTitle: 'Reports',
      filters: const ['All', 'Maintenance', 'Observation', 'Safety'],
      categoryMapper: CategoryMappers.simple(),
      categoryHighlighter: CategoryHighlighters.simple(['Maintenance', 'Observation', 'Safety']),
    ),
    
    ActivityScreenType.cyclesRecom: ActivityFilterConfig(
      screenTitle: 'Cycles & Recommendations',
      filters: const ['All', 'Recoms', 'Cycles'],
      categoryMapper: CategoryMappers.simple(),
      categoryHighlighter: CategoryHighlighters.simple(['Recoms', 'Cycles']),
    ),
    
    ActivityScreenType.allActivity: ActivityFilterConfig(
      screenTitle: 'All Activity Logs',
      filters: const ['All', 'Substrate', 'Alerts', 'Cycles', 'Reports'],
      categoryMapper: CategoryMappers.grouped({
        'Substrate': ['Greens', 'Browns', 'Compost'],
        'Alerts': ['Temperature', 'Moisture', 'Oxygen'],
        'Cycles': ['Recoms', 'Cycles'],
        'Reports': ['Maintenance', 'Observation', 'Safety'],
      }),
      categoryHighlighter: CategoryHighlighters.grouped({
        'Substrate': ['Greens', 'Browns', 'Compost'],
        'Alerts': ['Temperature', 'Moisture', 'Oxygen'],
        'Cycles': ['Recoms', 'Cycles'],
        'Reports': ['Maintenance', 'Observation', 'Safety'],
      }),
    ),
  };

  late final ActivityRepository _repository;
  late final ActivityFilterConfig _config;
  late final ActivityScreenType _screenType;

  // ===== BUILD METHOD - RIVERPOD ENTRY POINT =====

  @override
  ActivityListState build(ActivityParams params) {
    _repository = ref.read(activityRepositoryProvider);
    _screenType = params.screenType;
    _config = _configs[_screenType]!;
    
    final initialState = ActivityListState(
      selectedFilter: params.initialFilter ?? 'All',
      isManualFilter: params.initialFilter != null && params.initialFilter != 'All',
      focusedMachineId: params.focusedMachineId,
    );
    
    // Initialize asynchronously
    Future.microtask(() => _initialize(params.viewingOperatorId, params.focusedMachineId));
    
    return initialState;
  }

  // ===== CONFIGURATION GETTERS =====

  // ignore: avoid_public_notifier_properties
  String get screenTitle => _config.getTitle(machineId: state.focusedMachineId);
  // ignore: avoid_public_notifier_properties
  List<String> get filters => _config.filters;

  // ===== DATA FETCHING =====

  Future<List<ActivityLogItem>> _fetchData(String? viewingOperatorId) async {
    switch (_screenType) {
      case ActivityScreenType.substrates:
        return await _repository.getSubstrates();
      
      case ActivityScreenType.alerts:
        return await _repository.getAlerts();
      
      case ActivityScreenType.reports:
        return await _repository.getReports();
      
      case ActivityScreenType.cyclesRecom:
        return await _repository.getCyclesRecom();
      
      case ActivityScreenType.allActivity:
        return await _repository.getAllActivities();
    }
  }

  // ===== INITIALIZATION =====

  Future<void> _initialize(String? viewingOperatorId, String? focusedMachineId) async {
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

      // ❌ REMOVED: Upload mock data
      // await _repository.uploadMockData();

      await loadActivities(viewingOperatorId, focusedMachineId);
    } catch (e) {
      state = state.copyWith(
        status: LoadingStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  // ===== PUBLIC METHODS =====

  /// Load activities from repository
  Future<void> loadActivities(String? viewingOperatorId, String? focusedMachineId) async {
    try {
      List<ActivityLogItem> activities = await _fetchData(viewingOperatorId);  

      // Filter by machine if focusedMachineId is set
      if (focusedMachineId != null) {
        activities = activities
            .where((item) => item.machineId == focusedMachineId)
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
  Future<void> refresh(String? viewingOperatorId, String? focusedMachineId) async {
    await loadActivities(viewingOperatorId, focusedMachineId);
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

  List<ActivityLogItem> _applyDateFilter(List<ActivityLogItem> items) {  
    if (!state.dateFilter.isActive) return items;

    return items.where((item) {
      return item.timestamp.isAfter(state.dateFilter.startDate!) &&
          item.timestamp.isBefore(state.dateFilter.endDate!);
    }).toList();
  }

  List<ActivityLogItem> _applySearchFilter(List<ActivityLogItem> items) {  
    if (state.searchQuery.isEmpty) return items;

    return items
        .where((item) => item.matchesSearchQuery(state.searchQuery))
        .toList();
  }

  Set<String> _computeAutoHighlightedFilters(List<ActivityLogItem> searchResults) {  
    if (state.searchQuery.isEmpty) return {};

    final categories = searchResults.map((item) => item.category).toSet();
    return _config.categoryHighlighter(categories, _config.filters);
  }

  List<ActivityLogItem> _applyCategoryFilter(List<ActivityLogItem> items) {  
    // If manual filter is set and not 'All', apply category filter
    if (state.isManualFilter && state.selectedFilter != 'All') {
      return _config.categoryMapper<ActivityLogItem>(
        items,
        state.selectedFilter,
        (item) => item.category,
      );
    }

    // If 'All' or no manual filter, show all search results
    return items;
  }
}

// ===== SINGLE PARAMETER CLASS =====

class ActivityParams {
  final ActivityScreenType screenType;
  final String? initialFilter;
  final String? viewingOperatorId;
  final String? focusedMachineId;

  ActivityParams({
    required this.screenType,
    this.initialFilter,
    this.viewingOperatorId,
    this.focusedMachineId,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ActivityParams &&
          screenType == other.screenType &&
          initialFilter == other.initialFilter &&
          viewingOperatorId == other.viewingOperatorId &&
          focusedMachineId == other.focusedMachineId;

  @override
  int get hashCode =>
      screenType.hashCode ^
      initialFilter.hashCode ^
      viewingOperatorId.hashCode ^
      focusedMachineId.hashCode;
}