// lib/ui/reports/view_model/reports_viewmodel.dart

import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../data/models/report.dart';
import '../../../data/repositories/report_repository.dart';
import '../../../data/providers/report_providers.dart';
import '../../../services/sess_service.dart';
import '../models/reports_state.dart';

part 'reports_viewmodel.g.dart';

@riverpod
class ReportsViewModel extends _$ReportsViewModel {
  late final ReportRepository _repository;
  late final SessionService _sessionService;

  @override
  ReportsState build() {
    _repository = ref.read(reportRepositoryProvider);
    _sessionService = SessionService();
    
    Future.microtask(() => _initialize());
    
    return const ReportsState();
  }

  // ===== INITIALIZATION =====

  Future<void> _initialize() async {
    state = state.copyWith(
      status: LoadingStatus.loading,
      errorMessage: null,
    );

    try {
      final userData = await _sessionService.getCurrentUserData();
      final teamId = userData?['teamId'] as String?;

      if (teamId == null) {
        state = state.copyWith(
          status: LoadingStatus.success,
          isLoggedIn: false,
        );
        return;
      }

      state = state.copyWith(isLoggedIn: true);
      await loadReports(teamId);
    } catch (e) {
      state = state.copyWith(
        status: LoadingStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  // ===== DATA LOADING =====

  Future<void> loadReports(String teamId) async {
    try {
      state = state.copyWith(status: LoadingStatus.loading);

      final reports = await _repository.getReportsByTeam(teamId);

      state = state.copyWith(
        allReports: reports,
        status: LoadingStatus.success,
      );
    } catch (e) {
      state = state.copyWith(
        status: LoadingStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> refresh() async {
    final userData = await _sessionService.getCurrentUserData();
    final teamId = userData?['teamId'] as String?;
    
    if (teamId != null) {
      await loadReports(teamId);
    }
  }

  // ===== FILTER HANDLERS =====

  void onStatusChanged(ReportStatusFilter status) {
    state = state.copyWith(
      selectedStatus: status,
      currentPage: 1,
    );
  }

  void onCategoryChanged(ReportCategoryFilter category) {
    state = state.copyWith(
      selectedCategory: category,
      currentPage: 1,
    );
  }

  void onPriorityChanged(ReportPriorityFilter priority) {
    state = state.copyWith(
      selectedPriority: priority,
      currentPage: 1,
    );
  }

  void onDateFilterChanged(DateTime? start, DateTime? end) {
    state = state.copyWith(
      dateFilterStart: start,
      dateFilterEnd: end,
      currentPage: 1,
    );
  }

  void onSearchChanged(String query) {
    state = state.copyWith(
      searchQuery: query.toLowerCase(),
      currentPage: 1,
    );
  }

  // ===== SORTING HANDLERS =====

  void onSort(String column) {
    final isAscending = state.sortColumn == column ? !state.sortAscending : true;
    
    state = state.copyWith(
      sortColumn: column,
      sortAscending: isAscending,
    );
  }

  // ===== PAGINATION HANDLERS =====

  void onPageChanged(int page) {
    state = state.copyWith(currentPage: page);
  }

  void onItemsPerPageChanged(int itemsPerPage) {
    state = state.copyWith(
      itemsPerPage: itemsPerPage,
      currentPage: 1,
    );
  }

  // ===== STATS CALCULATIONS =====

  Map<String, Map<String, dynamic>> getStatsWithChange() {
    final now = DateTime.now();
    final currentMonthStart = DateTime(now.year, now.month, 1);
    final currentMonthEnd = now;
    final previousMonthStart = DateTime(now.year, now.month - 1, 1);
    final previousMonthEnd = DateTime(now.year, now.month, 1).subtract(const Duration(microseconds: 1));

    // All-time counts
    final allTimeCounts = _getAllTimeCounts();
    
    // Current month counts
    final currentCounts = _getCountsForDateRange(currentMonthStart, currentMonthEnd);
    
    // Previous month counts
    final previousCounts = _getCountsForDateRange(previousMonthStart, previousMonthEnd);

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
      final percentageChange = ((currentMonthCount - previousMonthCount) / previousMonthCount * 100).round();
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
      final request = UpdateReportRequest(
        reportId: reportId,
        title: title,
        description: description,
        status: status,
        priority: priority,
      );

      await _repository.updateReport(machineId, request);
      
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