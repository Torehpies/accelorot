// lib/ui/reports/view_model/mobile_reports_viewmodel.dart

import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../data/models/report.dart';
import '../../../data/providers/report_providers.dart';
import '../services/report_aggregator_service.dart';
import '../models/mobile_reports_state.dart';
import '../../activity_logs/models/activity_common.dart';
import '../models/report_filters.dart';

part 'mobile_reports_viewmodel.g.dart';

// ===== AGGREGATOR SERVICE PROVIDER =====
@riverpod
ReportAggregatorService mobileReportsAggregatorService(Ref ref) {
  final repository = ref.watch(reportRepositoryProvider);
  return ReportAggregatorService(reportRepo: repository);
}

// ===== MOBILE REPORTS VIEW MODEL =====
@riverpod
class MobileReportsViewModel extends _$MobileReportsViewModel {
  static const int _loadMoreIncrement = 5;
  
  late final ReportAggregatorService _aggregator;

  @override
  MobileReportsState build() {
    _aggregator = ref.read(mobileReportsAggregatorServiceProvider);
    return const MobileReportsState();
  }

  // ===== INITIALIZATION =====

  Future<void> initialize() async {
    state = state.copyWith(status: LoadingStatus.loading, errorMessage: null);

    try {
      final reports = await _aggregator.getReports()
          .timeout(const Duration(seconds: 10));
      
      state = state.copyWith(
        reports: reports,
        status: LoadingStatus.success,
      );
    } catch (e) {
      state = state.copyWith(
        status: LoadingStatus.error,
        errorMessage: 'Failed to load: ${e.toString().replaceAll('Exception:', '').trim()}',
      );
    }
  }

  Future<void> refresh() async {
    try {
      final reports = await _aggregator.getReports()
          .timeout(const Duration(seconds: 10));
      
      state = state.copyWith(reports: reports);
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Failed to refresh: ${e.toString().replaceAll('Exception:', '').trim()}',
      );
    }
  }

  // ===== MOBILE-SPECIFIC: STATUS FILTERING =====

  void setStatusFilter(ReportStatusFilter filter) {
    HapticFeedback.selectionClick();
    state = state.copyWith(
      selectedStatus: filter,
      searchQuery: '', // Clear search when switching status
      displayLimit: _loadMoreIncrement, // Reset to initial limit
    );
  }

  // ===== MOBILE-SPECIFIC: CATEGORY FILTERING =====

  void setCategoryFilter(ReportCategoryFilter filter) {
    HapticFeedback.selectionClick();
    state = state.copyWith(
      selectedCategory: filter,
      searchQuery: '', // Clear search when switching category
      displayLimit: _loadMoreIncrement, // Reset to initial limit
    );
  }

  // ===== MOBILE-SPECIFIC: PRIORITY FILTERING =====

  void setPriorityFilter(ReportPriorityFilter filter) {
    HapticFeedback.selectionClick();
    state = state.copyWith(
      selectedPriority: filter,
      searchQuery: '', // Clear search when switching priority
      displayLimit: _loadMoreIncrement, // Reset to initial limit
    );
  }

  // ===== MOBILE-SPECIFIC: LOAD-MORE PAGINATION =====

  void loadMore() {
    state = state.copyWith(
      displayLimit: state.displayLimit + _loadMoreIncrement,
    );
  }

  void resetDisplayLimit() {
    state = state.copyWith(displayLimit: _loadMoreIncrement);
  }

  // ===== SHARED: DATE FILTERING =====

  void setDateFilter(DateFilterRange dateFilter) {
    HapticFeedback.selectionClick();
    state = state.copyWith(
      dateFilter: dateFilter,
      displayLimit: _loadMoreIncrement, // Reset pagination
    );
  }

  void clearDateFilter() {
    state = state.copyWith(
      dateFilter: const DateFilterRange(type: DateFilterType.none),
      displayLimit: _loadMoreIncrement,
    );
  }

  // ===== SHARED: SEARCH FILTERING =====

  void setSearchQuery(String query) {
    state = state.copyWith(
      searchQuery: query,
      displayLimit: _loadMoreIncrement, // Reset pagination on search
    );
  }

  void clearSearch() {
    state = state.copyWith(
      searchQuery: '',
      displayLimit: _loadMoreIncrement,
    );
  }

  // ===== SHARED: SORTING =====

  void setSort(String sortBy) {
    state = state.copyWith(selectedSort: sortBy);
  }

  // ===== CLEAR ALL FILTERS =====

  void clearAllFilters() {
    state = state.copyWith(
      selectedStatus: ReportStatusFilter.all,
      selectedCategory: ReportCategoryFilter.all,
      selectedPriority: ReportPriorityFilter.all,
      dateFilter: const DateFilterRange(type: DateFilterType.none),
      searchQuery: '',
      displayLimit: _loadMoreIncrement,
    );
  }

  // ===== REPORT OPERATIONS =====

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

      await _aggregator.updateReport(
        machineId: machineId,
        request: request,
      );
      
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

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}