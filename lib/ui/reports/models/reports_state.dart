// lib/ui/reports/models/reports_state.dart

import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../data/models/report.dart';
import '../../activity_logs/models/activity_common.dart';

part 'reports_state.freezed.dart';

/// Report status filter options
enum ReportStatusFilter {
  all,
  open,
  inProgress,
  completed,
  onHold;

  String get displayName {
    switch (this) {
      case ReportStatusFilter.all:
        return 'All Status';
      case ReportStatusFilter.open:
        return 'Open';
      case ReportStatusFilter.inProgress:
        return 'In Progress';
      case ReportStatusFilter.completed:
        return 'Completed';
      case ReportStatusFilter.onHold:
        return 'On Hold';
    }
  }
}

/// Report category filter options
enum ReportCategoryFilter {
  all,
  maintenance,
  observation,
  safety;

  String get displayName {
    switch (this) {
      case ReportCategoryFilter.all:
        return 'All Categories';
      case ReportCategoryFilter.maintenance:
        return 'Maintenance';
      case ReportCategoryFilter.observation:
        return 'Observation';
      case ReportCategoryFilter.safety:
        return 'Safety';
    }
  }
}

/// Report priority filter options
enum ReportPriorityFilter {
  all,
  high,
  medium,
  low;

  String get displayName {
    switch (this) {
      case ReportPriorityFilter.all:
        return 'All Priorities';
      case ReportPriorityFilter.high:
        return 'High';
      case ReportPriorityFilter.medium:
        return 'Medium';
      case ReportPriorityFilter.low:
        return 'Low';
    }
  }
}

/// State for reports view
@freezed
abstract class ReportsState with _$ReportsState {
  const factory ReportsState({
    // Filters
    @Default(ReportStatusFilter.all) ReportStatusFilter selectedStatus,
    @Default(ReportCategoryFilter.all) ReportCategoryFilter selectedCategory,
    @Default(ReportPriorityFilter.all) ReportPriorityFilter selectedPriority,
    @Default(DateFilterRange(type: DateFilterType.none))
    DateFilterRange dateFilter,
    @Default('') String searchQuery,

    // Sorting
    String? sortColumn,
    @Default(true) bool sortAscending,

    // Data
    @Default([]) List<Report> allReports,
    @Default([]) List<Report> filteredReports,

    // Pagination
    @Default(1) int currentPage,
    @Default(10) int itemsPerPage,

    // UI state
    @Default(LoadingStatus.initial) LoadingStatus status,
    String? errorMessage,
    @Default(true) bool isLoggedIn,
  }) = _ReportsState;

  const ReportsState._();

  // ===== COMPUTED PROPERTIES =====

  bool get isLoading => status == LoadingStatus.loading;
  bool get hasError => status == LoadingStatus.error;
  bool get isEmpty =>
      filteredReports.isEmpty && status == LoadingStatus.success;

  /// Get paginated reports for current page
  List<Report> get paginatedReports {
    final startIndex = (currentPage - 1) * itemsPerPage;
    final endIndex = startIndex + itemsPerPage;

    if (startIndex >= filteredReports.length) {
      return [];
    }

    return filteredReports.sublist(
      startIndex,
      endIndex > filteredReports.length ? filteredReports.length : endIndex,
    );
  }

  /// Total number of pages
  int get totalPages {
    if (filteredReports.isEmpty) return 1;
    return (filteredReports.length / itemsPerPage).ceil();
  }

  /// Check if has any active filters
  bool get hasActiveFilters {
    return selectedStatus != ReportStatusFilter.all ||
        selectedCategory != ReportCategoryFilter.all ||
        selectedPriority != ReportPriorityFilter.all ||
        dateFilter.isActive ||
        searchQuery.isNotEmpty;
  }
}
