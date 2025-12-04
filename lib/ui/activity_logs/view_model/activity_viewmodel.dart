// lib/ui/activity_logs/view_model/activity_viewmodel.dart

import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../data/models/activity_log_item.dart';
import '../models/activity_list_state.dart';
import '../models/activity_filter_config.dart';
import '../services/activity_aggregator_service.dart';
import '../services/activity_filter_service.dart';
import '../../../data/providers/activity_providers.dart';
import 'substrate_config.dart';
import 'alert_config.dart';
import 'report_config.dart';
import 'cycle_config.dart';
import 'all_activity_config.dart';

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
    ActivityScreenType.substrates: SubstratesConfig.config,
    ActivityScreenType.alerts: AlertsConfig.config,
    ActivityScreenType.reports: ReportsConfig.config,
    ActivityScreenType.cyclesRecom: CyclesConfig.config,
    ActivityScreenType.allActivity: AllActivityConfig.config,
  };

  late final ActivityAggregatorService _aggregator;
  late final ActivityFilterService _filterService;
  late final ActivityFilterConfig _config;
  late final ActivityScreenType _screenType;

  // ===== BUILD METHOD - RIVERPOD ENTRY POINT =====

  @override
  ActivityListState build(ActivityParams params) {
    _aggregator = ref.read(activityAggregatorProvider);
    _filterService = ActivityFilterService();
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
        return await _aggregator.getSubstrates();
      
      case ActivityScreenType.alerts:
        return await _aggregator.getAlerts();
      
      case ActivityScreenType.reports:
        return await _aggregator.getReports();
      
      case ActivityScreenType.cyclesRecom:
        return await _aggregator.getCyclesRecom();
      
      case ActivityScreenType.allActivity:
        return await _aggregator.getAllActivities();
    }
  }

  // ===== INITIALIZATION =====

  Future<void> _initialize(String? viewingOperatorId, String? focusedMachineId) async {
    state = state.copyWith(
      status: LoadingStatus.loading,
      errorMessage: null,
    );

    try {
      final isLoggedIn = await _aggregator.isUserLoggedIn();

      if (!isLoggedIn) {
        state = state.copyWith(
          status: LoadingStatus.success,
          isLoggedIn: false,
        );
        return;
      }

      state = state.copyWith(isLoggedIn: true);

      await loadActivities(viewingOperatorId, focusedMachineId);
    } catch (e) {
      state = state.copyWith(
        status: LoadingStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  // ===== PUBLIC METHODS =====

  /// Load activities from aggregator service
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
    final result = _filterService.applyAllFilters(
      items: state.allActivities,
      selectedFilter: state.selectedFilter,
      searchQuery: state.searchQuery,
      dateFilter: state.dateFilter,
      config: _config,
      isManualFilter: state.isManualFilter,
    );

    state = state.copyWith(
      filteredActivities: result.filteredItems,
      autoHighlightedFilters: result.highlightedFilters,
    );
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