// lib/ui/reports/services/report_filter_service.dart

import '../../../data/models/report.dart';
import '../../activity_logs/models/activity_common.dart';
import '../models/report_filters.dart';

/// Service to handle all report filtering logic
class ReportFilterService {
  /// Apply all filters to reports
  FilterResult applyAllFilters({
    required List<Report> reports,
    required DateFilterRange dateFilter,
    required String searchQuery,
    required ReportStatusFilter selectedStatus,
    required ReportCategoryFilter selectedCategory,
    required ReportPriorityFilter selectedPriority,
    required String? sortColumn,
    required bool sortAscending,
  }) {
    var filtered = List<Report>.from(reports);

    // Step 1: Apply date filter
    filtered = applyDateFilter(filtered, dateFilter);

    // Step 2: Apply search filter
    filtered = applySearchFilter(filtered, searchQuery);

    // Step 3: Apply status filter
    filtered = applyStatusFilter(filtered, selectedStatus);

    // Step 4: Apply category filter
    filtered = applyCategoryFilter(filtered, selectedCategory);

    // Step 5: Apply priority filter
    filtered = applyPriorityFilter(filtered, selectedPriority);

    // Step 6: Apply sorting
    if (sortColumn != null) {
      filtered = applySorting(filtered, sortColumn, sortAscending);
    }

    return FilterResult(filteredReports: filtered);
  }

  /// Filter reports by date range
  List<Report> applyDateFilter(
    List<Report> reports,
    DateFilterRange dateFilter,
  ) {
    if (!dateFilter.isActive) return reports;

    return reports.where((report) {
      final reportDate = DateTime(
        report.createdAt.year,
        report.createdAt.month,
        report.createdAt.day,
      );

      final filterStartDate = DateTime(
        dateFilter.startDate!.year,
        dateFilter.startDate!.month,
        dateFilter.startDate!.day,
      );

      final filterEndDate = DateTime(
        dateFilter.endDate!.year,
        dateFilter.endDate!.month,
        dateFilter.endDate!.day,
      );

      // Inclusive start, exclusive end: [startDate, endDate)
      return !reportDate.isBefore(filterStartDate) &&
          reportDate.isBefore(filterEndDate);
    }).toList();
  }

  /// Filter reports by search query
  List<Report> applySearchFilter(List<Report> reports, String searchQuery) {
    if (searchQuery.isEmpty) return reports;

    final query = searchQuery.toLowerCase();
    return reports.where((report) {
      return report.title.toLowerCase().contains(query) ||
          report.description.toLowerCase().contains(query) ||
          report.userName.toLowerCase().contains(query) ||
          report.machineName.toLowerCase().contains(query) ||
          report.statusLabel.toLowerCase().contains(query) ||
          report.reportTypeLabel.toLowerCase().contains(query);
    }).toList();
  }

  /// Filter reports by status
  List<Report> applyStatusFilter(
    List<Report> reports,
    ReportStatusFilter statusFilter,
  ) {
    if (statusFilter == ReportStatusFilter.all) return reports;

    final targetStatus = _getStatusValue(statusFilter);
    return reports
        .where((report) => report.status.toLowerCase() == targetStatus)
        .toList();
  }

  /// Filter reports by category
  List<Report> applyCategoryFilter(
    List<Report> reports,
    ReportCategoryFilter categoryFilter,
  ) {
    if (categoryFilter == ReportCategoryFilter.all) return reports;

    final targetCategory = _getCategoryValue(categoryFilter);
    return reports
        .where((report) => report.reportType.toLowerCase() == targetCategory)
        .toList();
  }

  /// Filter reports by priority
  List<Report> applyPriorityFilter(
    List<Report> reports,
    ReportPriorityFilter priorityFilter,
  ) {
    if (priorityFilter == ReportPriorityFilter.all) return reports;

    final targetPriority = _getPriorityValue(priorityFilter);
    return reports
        .where((report) => report.priority.toLowerCase() == targetPriority)
        .toList();
  }

  /// Apply sorting to reports
  List<Report> applySorting(
    List<Report> reports,
    String sortColumn,
    bool ascending,
  ) {
    final sorted = List<Report>.from(reports);

    switch (sortColumn) {
      case 'title':
        sorted.sort((a, b) => a.title.compareTo(b.title));
        break;
      case 'date':
        sorted.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case 'status':
        sorted.sort((a, b) => a.status.compareTo(b.status));
        break;
      case 'priority':
        sorted.sort((a, b) => a.priority.compareTo(b.priority));
        break;
      default:
        return sorted;
    }

    return ascending ? sorted : sorted.reversed.toList();
  }

  // ===== HELPER METHODS =====

  String _getStatusValue(ReportStatusFilter filter) {
    switch (filter) {
      case ReportStatusFilter.open:
        return 'open';
      case ReportStatusFilter.inProgress:
        return 'in_progress';
      case ReportStatusFilter.completed:
        return 'completed';
      case ReportStatusFilter.onHold:
        return 'on_hold';
      case ReportStatusFilter.all:
        return '';
    }
  }

  String _getCategoryValue(ReportCategoryFilter filter) {
    switch (filter) {
      case ReportCategoryFilter.maintenance:
        return 'maintenance_issue';
      case ReportCategoryFilter.observation:
        return 'observation';
      case ReportCategoryFilter.safety:
        return 'safety_concern';
      case ReportCategoryFilter.all:
        return '';
    }
  }

  String _getPriorityValue(ReportPriorityFilter filter) {
    switch (filter) {
      case ReportPriorityFilter.high:
        return 'high';
      case ReportPriorityFilter.medium:
        return 'medium';
      case ReportPriorityFilter.low:
        return 'low';
      case ReportPriorityFilter.all:
        return '';
    }
  }
}

/// Result object containing filtered reports
class FilterResult {
  final List<Report> filteredReports;

  const FilterResult({required this.filteredReports});
}
