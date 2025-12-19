// lib/ui/activity_logs/view_model/unified_activity_viewmodel.dart

import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../data/models/activity_log_item.dart';
import '../models/unified_activity_state.dart';
import '../models/unified_activity_config.dart';
import '../services/activity_aggregator_service.dart';
import '../../../data/providers/activity_providers.dart';
import '../models/activity_common.dart';

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
      await loadActivities();
    } catch (e) {
      state = state.copyWith(
        status: LoadingStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  // ===== DATA LOADING =====

  /// Load all activities from aggregator service
  Future<void> loadActivities() async {
    try {
      state = state.copyWith(status: LoadingStatus.loading);

      final activities = await _aggregator.getAllActivities();

      state = state.copyWith(
        allActivities: activities,
        status: LoadingStatus.success,
      );

      // Apply filters to new data
      _applyFilters();
    } catch (e) {
      state = state.copyWith(
        status: LoadingStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  /// Refresh data (for pull-to-refresh)
  Future<void> refresh() async {
    await loadActivities();
  }

  // ===== FILTER HANDLERS =====

  void onMachineChanged(String? machineId) {
    state = state.copyWith(
      selectedMachineId: machineId,
      selectedBatchId: null, // Reset batch when machine changes
      currentPage: 1, // Reset to first page
    );
    _applyFilters();
  }

  void onBatchChanged(String? batchId) {
    state = state.copyWith(
      selectedBatchId: batchId,
      currentPage: 1,
    );
    _applyFilters();
  }

  void onDateFilterChanged(DateFilterRange dateFilter) {
    state = state.copyWith(
      dateFilter: dateFilter,
      currentPage: 1,
    );
    _applyFilters();
  }

  void onSearchChanged(String query) {
    state = state.copyWith(
      searchQuery: query.toLowerCase(),
      currentPage: 1,
    );
    _applyFilters();
  }

  void onCategoryChanged(String category) {
    // When category changes, reset type to 'All'
    state = state.copyWith(
      selectedCategory: category,
      selectedType: 'All',
      currentPage: 1,
    );
    _applyFilters();
  }

  void onTypeChanged(String type) {
    state = state.copyWith(
      selectedType: type,
      currentPage: 1,
    );
    _applyFilters();
  }

  // ===== SORTING HANDLERS =====

  void onSort(String column) {
    final isAscending = state.sortColumn == column ? !state.sortAscending : true;
    
    state = state.copyWith(
      sortColumn: column,
      sortAscending: isAscending,
    );
    
    _applyFilters(); // Reapply filters with new sort
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
      filtered = filtered.where((item) => 
        item.machineId == state.selectedMachineId
      ).toList();
    }

    // 2. Filter by Batch
    if (state.selectedBatchId != null) {
      filtered = filtered.where((item) => 
        item.batchId == state.selectedBatchId
      ).toList();
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
      filtered = filtered.where((item) => 
        item.matchesSearchQuery(state.searchQuery)
      ).toList();
    }

    // 5. Filter by Category (maps to ActivityType)
    if (state.selectedCategory != 'All') {
      final typeFilter = UnifiedActivityConfig.getActivityTypeFromCategory(
        state.selectedCategory
      );
      if (typeFilter != null) {
        filtered = filtered.where((item) => item.type == typeFilter).toList();
      }
    }

    // 6. Filter by Type (granular category)
    if (state.selectedType != 'All') {
      filtered = filtered.where((item) => 
        item.category.toLowerCase() == state.selectedType.toLowerCase()
      ).toList();
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

  /// Get count for each category (ALWAYS from ALL activities, not filtered)
  /// This ensures stats remain constant regardless of filters
  Map<String, int> getCategoryCounts() {
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
  /// Count = total all-time, Change = this month vs last month comparison
  Map<String, Map<String, dynamic>> getCategoryCountsWithChange() {
    final now = DateTime.now();
    
    // Current month: from start of this month to now
    final currentMonthStart = DateTime(now.year, now.month, 1);
    final currentMonthEnd = now;
    
    // Previous month: full month
    final previousMonthStart = DateTime(now.year, now.month - 1, 1);
    final previousMonthEnd = DateTime(now.year, now.month, 1).subtract(const Duration(microseconds: 1));

    // Get ALL-TIME counts (for display)
    final allTimeCounts = getCategoryCounts();
    
    // Get counts for current month (for comparison)
    final currentCounts = _getCountsForDateRange(currentMonthStart, currentMonthEnd);
    
    // Get counts for previous month (for comparison)
    final previousCounts = _getCountsForDateRange(previousMonthStart, previousMonthEnd);

    return {
      'substrates': _buildChangeData(
        allTimeCounts['substrates']!,
        currentCounts['substrates']!,
        previousCounts['substrates']!,
      ),
      'alerts': _buildChangeData(
        allTimeCounts['alerts']!,
        currentCounts['alerts']!,
        previousCounts['alerts']!,
      ),
      'operations': _buildChangeData(
        allTimeCounts['operations']!,
        currentCounts['operations']!,
        previousCounts['operations']!,
      ),
      'reports': _buildChangeData(
        allTimeCounts['reports']!,
        currentCounts['reports']!,
        previousCounts['reports']!,
      ),
    };
  }

  /// Helper: Get counts for a specific date range
  Map<String, int> _getCountsForDateRange(DateTime start, DateTime end) {
    final activitiesInRange = state.allActivities.where((item) {
      return item.timestamp.isAfter(start) && item.timestamp.isBefore(end);
    }).toList();

    return {
      'substrates': activitiesInRange
          .where((item) => item.type == ActivityType.substrate)
          .length,
      'alerts': activitiesInRange
          .where((item) => item.type == ActivityType.alert)
          .length,
      'operations': activitiesInRange
          .where((item) => item.type == ActivityType.cycle)
          .length,
      'reports': activitiesInRange
          .where((item) => item.type == ActivityType.report)
          .length,
    };
  }

  /// Helper: Build change data with percentage and positive/negative indicator
  /// allTimeCount = total count to display
  /// currentMonthCount = this month's count for comparison
  /// previousMonthCount = last month's count for comparison
  Map<String, dynamic> _buildChangeData(
    int allTimeCount,
    int currentMonthCount,
    int previousMonthCount,
  ) {
    String changeText;
    bool isPositive = true;

    if (previousMonthCount == 0 && currentMonthCount > 0) {
      // New this month
      changeText = 'New';
      isPositive = true;
    } else if (previousMonthCount == 0 && currentMonthCount == 0) {
      // No data yet
      changeText = 'No log yet';
      isPositive = true; // Neutral
    } else {
      // Calculate percentage change (current month vs previous month)
      final percentageChange = ((currentMonthCount - previousMonthCount) / previousMonthCount * 100).round();
      isPositive = percentageChange >= 0;
      final sign = isPositive ? '+' : '';
      changeText = '$sign$percentageChange%';
    }

    return {
      'count': allTimeCount, // Show total all-time count
      'change': changeText,
      'isPositive': isPositive,
    };
  }
}