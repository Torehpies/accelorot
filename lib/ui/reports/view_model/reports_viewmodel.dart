// lib/ui/reports/view_model/reports_viewmodel.dart

import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../data/providers/report_providers.dart';
import '../../../data/models/report.dart';
import '../services/report_aggregator_service.dart';
import '../services/report_filter_service.dart';
import '../models/reports_state.dart';
import '../../activity_logs/models/activity_common.dart';
import '../models/report_filters.dart';

part 'reports_viewmodel.g.dart';

@riverpod
class ReportsViewModel extends _$ReportsViewModel {
  late final ReportAggregatorService _aggregator;
  late final ReportFilterService _filterService;

  @override
  ReportsState build() {
    _aggregator = ref.read(reportAggregatorProvider);
    _filterService = ReportFilterService();

    Future.microtask(() => _initialize());

    return const ReportsState();
  }

  // ===== INITIALIZATION =====

  Future<void> _initialize() async {
    state = state.copyWith(status: LoadingStatus.loading, errorMessage: null);

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
      await loadReports();
    } catch (e) {
      state = state.copyWith(
        status: LoadingStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  // ===== DATA LOADING =====

  Future<void> loadReports() async {
    try {
      state = state.copyWith(status: LoadingStatus.loading);

      final reports = await _aggregator.getReports();

      state = state.copyWith(
        allReports: reports,
        status: LoadingStatus.success,
      );

      // Apply filters to the newly loaded data
      _applyFilters();
    } catch (e) {
      state = state.copyWith(
        status: LoadingStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> refresh() async {
    await loadReports();
  }

  // ===== FILTER HANDLERS =====

  void onStatusChanged(ReportStatusFilter status) {
    state = state.copyWith(selectedStatus: status, currentPage: 1);
    _applyFilters();
  }

  void onCategoryChanged(ReportCategoryFilter category) {
    state = state.copyWith(selectedCategory: category, currentPage: 1);
    _applyFilters();
  }

  void onPriorityChanged(ReportPriorityFilter priority) {
    state = state.copyWith(selectedPriority: priority, currentPage: 1);
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
    state = state.copyWith(itemsPerPage: itemsPerPage, currentPage: 1);
  }

  // ===== FILTERING LOGIC =====

  /// Apply all filters using the filter service
  void _applyFilters() {
    final result = _filterService.applyAllFilters(
      reports: state.allReports,
      dateFilter: state.dateFilter,
      searchQuery: state.searchQuery,
      selectedStatus: state.selectedStatus,
      selectedCategory: state.selectedCategory,
      selectedPriority: state.selectedPriority,
      sortColumn: state.sortColumn,
      sortAscending: state.sortAscending,
    );

    state = state.copyWith(filteredReports: result.filteredReports);
  }

  // ===== STATS CALCULATIONS =====

  Map<String, Map<String, dynamic>> getStatsWithChange() {
    final now = DateTime.now();
    final currentMonthStart = DateTime(now.year, now.month, 1);
    final currentMonthEnd = now;
    final previousMonthStart = DateTime(now.year, now.month - 1, 1);
    final previousMonthEnd = DateTime(
      now.year,
      now.month,
      1,
    ).subtract(const Duration(microseconds: 1));

    // All-time counts
    final allTimeCounts = _getAllTimeCounts();

    // Current month counts
    final currentCounts = _getCountsForDateRange(
      currentMonthStart,
      currentMonthEnd,
    );

    // Previous month counts
    final previousCounts = _getCountsForDateRange(
      previousMonthStart,
      previousMonthEnd,
    );

    return {
      'completed': _buildChangeData(
        allTimeCounts['completed']!,
        currentCounts['completed']!,
        previousCounts['completed']!,
      ),
      'open': _buildChangeData(
        allTimeCounts['open']!,
        currentCounts['open']!,
        previousCounts['open']!,
      ),
      'inProgress': _buildChangeData(
        allTimeCounts['inProgress']!,
        currentCounts['inProgress']!,
        previousCounts['inProgress']!,
      ),
      'onHold': _buildChangeData(
        allTimeCounts['onHold']!,
        currentCounts['onHold']!,
        previousCounts['onHold']!,
      ),
    };
  }

  Map<String, int> _getAllTimeCounts() {
    return {
      'completed': state.allReports
          .where((r) => r.status.toLowerCase() == 'completed')
          .length,
      'open': state.allReports
          .where((r) => r.status.toLowerCase() == 'open')
          .length,
      'inProgress': state.allReports
          .where((r) => r.status.toLowerCase() == 'in_progress')
          .length,
      'onHold': state.allReports
          .where((r) => r.status.toLowerCase() == 'on_hold')
          .length,
    };
  }

  Map<String, int> _getCountsForDateRange(DateTime start, DateTime end) {
    final reportsInRange = state.allReports.where((r) {
      return r.createdAt.isAfter(start) && r.createdAt.isBefore(end);
    }).toList();

    return {
      'completed': reportsInRange
          .where((r) => r.status.toLowerCase() == 'completed')
          .length,
      'open': reportsInRange
          .where((r) => r.status.toLowerCase() == 'open')
          .length,
      'inProgress': reportsInRange
          .where((r) => r.status.toLowerCase() == 'in_progress')
          .length,
      'onHold': reportsInRange
          .where((r) => r.status.toLowerCase() == 'on_hold')
          .length,
    };
  }

  Map<String, dynamic> _buildChangeData(
    int allTimeCount,
    int currentMonthCount,
    int previousMonthCount,
  ) {
    String changeText;
    bool isPositive = true;

    if (previousMonthCount == 0 && currentMonthCount > 0) {
      changeText = 'New';
      isPositive = true;
    } else if (previousMonthCount == 0 && currentMonthCount == 0) {
      changeText = 'No log yet';
      isPositive = true;
    } else {
      final percentageChange =
          ((currentMonthCount - previousMonthCount) / previousMonthCount * 100)
              .round();
      isPositive = percentageChange >= 0;
      final sign = isPositive ? '+' : '';
      changeText = '$sign$percentageChange%';
    }

    return {
      'count': allTimeCount,
      'change': changeText,
      'isPositive': isPositive,
    };
  }

  // ===== UPDATE REPORT =====

  Future<void> updateReport({
    required String machineId,
    required String reportId,
    String? title,
    String? description,
    String? status,
    String? priority,
  }) async {
    try {
      // Create request object
      final request = UpdateReportRequest(
        reportId: reportId,
        title: title,
        description: description,
        status: status,
        priority: priority,
      );

      await _aggregator.updateReport(machineId: machineId, request: request);

      // Refresh after update
      await Future.delayed(const Duration(milliseconds: 500));
      await refresh();
    } catch (e) {
      state = state.copyWith(
        status: LoadingStatus.error,
        errorMessage: 'Failed to update report: $e',
      );
      rethrow;
    }
  }
}
