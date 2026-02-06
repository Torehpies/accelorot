// lib/ui/activity_logs/view_model/unified_activity_viewmodel.dart

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../data/models/activity_log_item.dart';
import '../models/unified_activity_state.dart';
import '../models/activity_enums.dart';
import '../services/activity_aggregator_service.dart';
import '../../../data/providers/activity_providers.dart';
import '../models/activity_common.dart';
import '../mappers/activity_presentation_mapper.dart';

part 'unified_activity_viewmodel.g.dart';

@riverpod
class UnifiedActivityViewModel extends _$UnifiedActivityViewModel {
  late final ActivityAggregatorService _aggregator;

  @override
  UnifiedActivityState build() {
    _aggregator = ref.read(activityAggregatorProvider);

    // Initialize asynchronously
    Future.microtask(() => _initialize());

    return const UnifiedActivityState();
  }

  // ===== INITIALIZATION =====

  Future<void> _initialize() async {
    final vmStopwatch = Stopwatch()..start();
    debugPrint('🚀 ViewModel initialization started');

    state = state.copyWith(
      status: LoadingStatus.loading,
      isLoggedIn: true,
      errorMessage: null,
    );

    vmStopwatch.stop();
    debugPrint(
      '🏁 ViewModel initialization complete: ${vmStopwatch.elapsedMilliseconds}ms\n',
    );

    unawaited(loadActivities());
  }

  // ===== DATA LOADING =====

  /// Load all activities with progressive loading - each category updates UI as it arrives
  Future<void> loadActivities() async {
    final loadStopwatch = Stopwatch()..start();
    debugPrint('🔄 loadActivities() called - Progressive Loading Mode');

    try {
      // Set all categories to loading state
      state = state.copyWith(
        status: LoadingStatus.loading,
        substratesLoadingStatus: LoadingStatus.loading,
        alertsLoadingStatus: LoadingStatus.loading,
        cyclesLoadingStatus: LoadingStatus.loading,
        reportsLoadingStatus: LoadingStatus.loading,
      );

      // PROGRESSIVE LOADING: Launch all fetches in parallel (fire and forget)
      // Each will update UI independently as it completes
      unawaited(_fetchSubstratesProgressive());
      unawaited(_fetchAlertsProgressive());
      unawaited(_fetchCyclesProgressive());
      unawaited(_fetchReportsProgressive());

      loadStopwatch.stop();
      debugPrint(
        '✅ Progressive loading launched: ${loadStopwatch.elapsedMilliseconds}ms (fetches running in background)\n',
      );
    } catch (e) {
      loadStopwatch.stop();
      debugPrint(
        '❌ loadActivities() failed: ${loadStopwatch.elapsedMilliseconds}ms - Error: $e\n',
      );

      state = state.copyWith(
        status: LoadingStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  /// Fetch substrates and update UI immediately when done
  Future<void> _fetchSubstratesProgressive() async {
    final stopwatch = Stopwatch()..start();

    try {
      debugPrint('🟢 Fetching substrates...');
      final substrates = await _aggregator.getSubstratesRaw();

      stopwatch.stop();
      debugPrint(
        '✅ Substrates fetched: ${stopwatch.elapsedMilliseconds}ms (${substrates.length} items)',
      );

      // ✅ Build category-specific list (NO race condition)
      final substrateActivityList = <ActivityLogItem>[];
      final newCache = Map<String, dynamic>.from(state.entityCache);

      for (var substrate in substrates) {
        newCache['substrate_${substrate.id}'] = substrate;
        substrateActivityList.add(
          ActivityPresentationMapper.fromSubstrate(substrate),
        );
      }

      // Update state - UI will reflect immediately!
      state = state.copyWith(
        substrateActivities: substrateActivityList,
        entityCache: newCache,
        substratesLoadingStatus: LoadingStatus.success,
        fullCategoryCounts: {
          ...state.fullCategoryCounts,
          'substrates': substrates.length,
        },
      );

      _mergeAllActivities();
      _applyFilters();
      _checkIfAllLoaded();
    } catch (e) {
      stopwatch.stop();
      debugPrint(
        '❌ Substrates fetch failed: ${stopwatch.elapsedMilliseconds}ms - $e',
      );

      state = state.copyWith(substratesLoadingStatus: LoadingStatus.error);
    }
  }

  /// Fetch alerts and update UI immediately when done
  Future<void> _fetchAlertsProgressive() async {
    final stopwatch = Stopwatch()..start();

    try {
      debugPrint('🟡 Fetching alerts...');
      final cutoffDate = DateTime.now().subtract(const Duration(days: 2));
      final alerts = await _aggregator.getAlertsRaw(
        cutoffDate: cutoffDate,
        limit: null,
      );

      stopwatch.stop();
      debugPrint(
        '✅ Alerts fetched: ${stopwatch.elapsedMilliseconds}ms (${alerts.length} items)',
      );

      // ✅ Build category-specific list (NO race condition)
      final alertActivityList = <ActivityLogItem>[];
      final newCache = Map<String, dynamic>.from(state.entityCache);

      for (var alert in alerts) {
        newCache['alert_${alert.id}'] = alert;
        alertActivityList.add(ActivityPresentationMapper.fromAlert(alert));
      }

      // Update state - UI will reflect immediately!
      state = state.copyWith(
        alertActivities: alertActivityList,
        entityCache: newCache,
        alertsLoadingStatus: LoadingStatus.success,
        fullCategoryCounts: {
          ...state.fullCategoryCounts,
          'alerts': alerts.length,
        },
      );

      _mergeAllActivities();
      _applyFilters();
      _checkIfAllLoaded();
    } catch (e) {
      stopwatch.stop();
      debugPrint(
        '❌ Alerts fetch failed: ${stopwatch.elapsedMilliseconds}ms - $e',
      );

      state = state.copyWith(alertsLoadingStatus: LoadingStatus.error);
    }
  }

  /// Fetch cycles and update UI immediately when done
  Future<void> _fetchCyclesProgressive() async {
    final stopwatch = Stopwatch()..start();

    try {
      debugPrint('🟣 Fetching cycles...');
      final cutoffDate = DateTime.now().subtract(const Duration(days: 2));
      final cycles = await _aggregator.getCyclesRaw(
        cutoffDate: cutoffDate,
        limit: null,
      );

      stopwatch.stop();
      debugPrint(
        '✅ Cycles fetched: ${stopwatch.elapsedMilliseconds}ms (${cycles.length} items)',
      );

      // ✅ Build category-specific list (NO race condition)
      final cycleActivityList = <ActivityLogItem>[];
      final newCache = Map<String, dynamic>.from(state.entityCache);

      for (var cycle in cycles) {
        newCache['cycle_${cycle.id}'] = cycle;
        cycleActivityList.add(
          ActivityPresentationMapper.fromCycleRecommendation(cycle),
        );
      }

      // Update state - UI will reflect immediately!
      state = state.copyWith(
        cycleActivities: cycleActivityList,
        entityCache: newCache,
        cyclesLoadingStatus: LoadingStatus.success,
        fullCategoryCounts: {
          ...state.fullCategoryCounts,
          'operations': cycles.length,
        },
      );

      _mergeAllActivities();
      _applyFilters();
      _checkIfAllLoaded();
    } catch (e) {
      stopwatch.stop();
      debugPrint(
        '❌ Cycles fetch failed: ${stopwatch.elapsedMilliseconds}ms - $e',
      );

      state = state.copyWith(cyclesLoadingStatus: LoadingStatus.error);
    }
  }

  /// Fetch reports and update UI immediately when done
  Future<void> _fetchReportsProgressive() async {
    final stopwatch = Stopwatch()..start();

    try {
      debugPrint('🔵 Fetching reports...');
      final reports = await _aggregator.getReportsRaw(limit: null);

      stopwatch.stop();
      debugPrint(
        '✅ Reports fetched: ${stopwatch.elapsedMilliseconds}ms (${reports.length} items)',
      );

      // ✅ Build category-specific list (NO race condition)
      final reportActivityList = <ActivityLogItem>[];
      final newCache = Map<String, dynamic>.from(state.entityCache);

      for (var report in reports) {
        newCache['report_${report.id}'] = report;
        reportActivityList.add(ActivityPresentationMapper.fromReport(report));
      }

      // Update state - UI will reflect immediately!
      state = state.copyWith(
        reportActivities: reportActivityList,
        entityCache: newCache,
        reportsLoadingStatus: LoadingStatus.success,
        fullCategoryCounts: {
          ...state.fullCategoryCounts,
          'reports': reports.length,
        },
      );

      _mergeAllActivities();
      _applyFilters();
      _checkIfAllLoaded();
    } catch (e) {
      stopwatch.stop();
      debugPrint(
        '❌ Reports fetch failed: ${stopwatch.elapsedMilliseconds}ms - $e',
      );

      state = state.copyWith(reportsLoadingStatus: LoadingStatus.error);
    }
  }

  /// Check if all categories are loaded and update global status
  void _checkIfAllLoaded() {
    final allLoaded =
        state.substratesLoadingStatus == LoadingStatus.success &&
        state.alertsLoadingStatus == LoadingStatus.success &&
        state.cyclesLoadingStatus == LoadingStatus.success &&
        state.reportsLoadingStatus == LoadingStatus.success;

    if (allLoaded) {
      state = state.copyWith(status: LoadingStatus.success);
      debugPrint('loaded successfully!');
    }
  }

  /// Merge all category-specific lists into allActivities and sort by timestamp
  void _mergeAllActivities() {
    final merged = <ActivityLogItem>[
      ...state.substrateActivities,
      ...state.alertActivities,
      ...state.cycleActivities,
      ...state.reportActivities,
    ];

    // Sort by timestamp (newest first)
    merged.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    state = state.copyWith(allActivities: merged);
  }

  /// Refresh data (for pull-to-refresh)
  Future<void> refresh() async {
    final refreshStopwatch = Stopwatch()..start();
    debugPrint('🔃 refresh() called');

    await loadActivities();

    refreshStopwatch.stop();
    debugPrint(
      '✅ refresh() complete: ${refreshStopwatch.elapsedMilliseconds}ms\n',
    );
  }

  // ===== ENTITY CACHE LOOKUP =====

  /// Get full entity from cache for dialog display
  /// Returns the full entity (Alert, Substrate, Report, or CycleRecommendation)
  dynamic getFullEntity(ActivityLogItem item) {
    final key = '${item.type.name}_${item.id}';
    return state.entityCache[key];
  }

  // ===== FILTER HANDLERS =====

  void onMachineChanged(String? machineId) {
    state = state.copyWith(
      selectedMachineId: machineId,
      selectedBatchId: null,
      currentPage: 1,
    );
    _applyFilters();
  }

  void onBatchChanged(String? batchId) {
    state = state.copyWith(selectedBatchId: batchId, currentPage: 1);
    _applyFilters();
  }

  void onDateFilterChanged(DateFilterRange dateFilter) {
    state = state.copyWith(dateFilter: dateFilter, currentPage: 1);
    _applyFilters();
  }

  void onSearchChanged(String query) {
    state = state.copyWith(searchQuery: query.toLowerCase(), currentPage: 1);
    _applyFilters();
  }

  void onCategoryChanged(ActivityCategory category) {
    // When category changes, reset type to 'All'
    state = state.copyWith(
      selectedCategory: category,
      selectedType: ActivitySubType.all,
      currentPage: 1,
    );
    _applyFilters();
  }

  void onTypeChanged(ActivitySubType type) {
    state = state.copyWith(selectedType: type, currentPage: 1);
    _applyFilters();
  }

  // ===== SORTING HANDLERS =====

  void onSort(String column) {
    final isAscending = state.sortColumn == column
        ? !state.sortAscending
        : true;

    state = state.copyWith(sortColumn: column, sortAscending: isAscending);

    _applyFilters();
  }

  // ===== PAGINATION HANDLERS =====

  void onPageChanged(int page) {
    state = state.copyWith(currentPage: page);
  }

  void onItemsPerPageChanged(int itemsPerPage) {
    state = state.copyWith(
      itemsPerPage: itemsPerPage,
      currentPage: 1, // Reset to first page
    );
  }

  // ===== FILTERING LOGIC =====

  void _applyFilters() {
    var filtered = state.allActivities;

    // 1. Filter by Machine
    if (state.selectedMachineId != null) {
      filtered = filtered
          .where((item) => item.machineId == state.selectedMachineId)
          .toList();
    }

    // 2. Filter by Batch
    if (state.selectedBatchId != null) {
      filtered = filtered
          .where((item) => item.batchId == state.selectedBatchId)
          .toList();
    }

    // 3. Filter by Date
    if (state.dateFilter.isActive) {
      filtered = filtered.where((item) {
        final start = state.dateFilter.startDate;
        final end = state.dateFilter.endDate;
        if (start == null || end == null) return true;
        return item.timestamp.isAfter(start) && item.timestamp.isBefore(end);
      }).toList();
    }

    // 4. Filter by Search Query
    if (state.searchQuery.isNotEmpty) {
      filtered = filtered
          .where((item) => item.matchesSearchQuery(state.searchQuery))
          .toList();
    }

    // 5. Filter by Category
    if (state.selectedCategory != ActivityCategory.all) {
      final typeFilter = state.selectedCategory.toActivityType();
      if (typeFilter != null) {
        filtered = filtered.where((item) => item.type == typeFilter).toList();
      }
    }

    // 6. Filter by Type
    if (state.selectedType != ActivitySubType.all) {
      filtered = filtered
          .where(
            (item) =>
                item.category.toLowerCase() ==
                state.selectedType.displayName.toLowerCase(),
          )
          .toList();
    }

    // 7. Apply Sorting
    if (state.sortColumn != null) {
      filtered = _sortData(filtered, state.sortColumn!, state.sortAscending);
    }

    state = state.copyWith(filteredActivities: filtered);
  }

  // ===== SORTING LOGIC =====

  List<ActivityLogItem> _sortData(
    List<ActivityLogItem> items,
    String column,
    bool ascending,
  ) {
    final sorted = List<ActivityLogItem>.from(items);

    switch (column) {
      case 'title':
        sorted.sort((a, b) => a.title.compareTo(b.title));
        break;
      case 'date':
        sorted.sort((a, b) => a.timestamp.compareTo(b.timestamp));
        break;
      case 'value':
        sorted.sort((a, b) => a.value.compareTo(b.value));
        break;
      default:
        return sorted;
    }

    return ascending ? sorted : sorted.reversed.toList();
  }

  // ===== STATS CALCULATIONS =====

  /// Get count for each category from stored full counts
  Map<String, int> getCategoryCounts() {
    // Use stored full counts (fetched separately for stats cards)
    // If not available, fall back to counting from allActivities
    if (state.fullCategoryCounts.isNotEmpty) {
      return state.fullCategoryCounts;
    }

    // Fallback: count from allActivities (limited data)
    return {
      'substrates': state.allActivities
          .where((item) => item.type == ActivityType.substrate)
          .length,
      'alerts': state.allActivities
          .where((item) => item.type == ActivityType.alert)
          .length,
      'operations': state.allActivities
          .where((item) => item.type == ActivityType.cycle)
          .length,
      'reports': state.allActivities
          .where((item) => item.type == ActivityType.report)
          .length,
    };
  }

  /// Get category counts with month-over-month change percentage
  /// Note: Stats cards now show "last 2 days" counts, not month-over-month changes
  Map<String, Map<String, dynamic>> getCategoryCountsWithChange() {
    // Get counts from stored full counts (last 2 days for alerts/cycles, all-time for others)
    final counts = getCategoryCounts();

    // For now, we just show the counts without change percentages
    // since we're showing "last 2 days" counts instead of monthly trends
    return {
      'substrates': {
        'count': counts['substrates'] ?? 0,
        'change': '', 
        'isPositive': true,
      },
      'alerts': {
        'count': counts['alerts'] ?? 0,
        'change': '', 
        'isPositive': true,
      },
      'operations': {
        'count': counts['operations'] ?? 0,
        'change': '', 
        'isPositive': true,
      },
      'reports': {
        'count': counts['reports'] ?? 0,
        'change': '', 
        'isPositive': true,
      },
    };
  }
}
