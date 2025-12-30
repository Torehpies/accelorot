// lib/ui/reports/models/reports_state.dart

import '../../../data/models/report.dart';

enum LoadingStatus { idle, loading, success, error }

enum ReportStatusFilter { all, open, inProgress, completed, onHold }

enum ReportCategoryFilter { all, maintenanceIssue, observation, safetyConcern }

enum ReportPriorityFilter { all, low, medium, high }

/// State model for web reports view (pagination-based, not load-more)
class ReportsState {
  final List<Report> allReports;
  final LoadingStatus status;
  final String? errorMessage;
  final bool isLoggedIn;
  
  // Filters
  final String searchQuery;
  final ReportStatusFilter selectedStatus;
  final ReportCategoryFilter selectedCategory;
  final ReportPriorityFilter selectedPriority;
  final DateTime? dateFilterStart;
  final DateTime? dateFilterEnd;
  
  // Sorting
  final String? sortColumn;
  final bool sortAscending;
  
  // Pagination
  final int currentPage;
  final int itemsPerPage;

  const ReportsState({
    this.allReports = const [],
    this.status = LoadingStatus.idle,
    this.errorMessage,
    this.isLoggedIn = false,
    this.searchQuery = '',
    this.selectedStatus = ReportStatusFilter.all,
    this.selectedCategory = ReportCategoryFilter.all,
    this.selectedPriority = ReportPriorityFilter.all,
    this.dateFilterStart,
    this.dateFilterEnd,
    this.sortColumn,
    this.sortAscending = true,
    this.currentPage = 1,
    this.itemsPerPage = 10,
  });

  ReportsState copyWith({
    List<Report>? allReports,
    LoadingStatus? status,
    String? errorMessage,
    bool? isLoggedIn,
    String? searchQuery,
    ReportStatusFilter? selectedStatus,
    ReportCategoryFilter? selectedCategory,
    ReportPriorityFilter? selectedPriority,
    DateTime? dateFilterStart,
    DateTime? dateFilterEnd,
    String? sortColumn,
    bool? sortAscending,
    int? currentPage,
    int? itemsPerPage,
  }) {
    return ReportsState(
      allReports: allReports ?? this.allReports,
      status: status ?? this.status,
      errorMessage: errorMessage,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedStatus: selectedStatus ?? this.selectedStatus,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      selectedPriority: selectedPriority ?? this.selectedPriority,
      dateFilterStart: dateFilterStart ?? this.dateFilterStart,
      dateFilterEnd: dateFilterEnd ?? this.dateFilterEnd,
      sortColumn: sortColumn ?? this.sortColumn,
      sortAscending: sortAscending ?? this.sortAscending,
      currentPage: currentPage ?? this.currentPage,
      itemsPerPage: itemsPerPage ?? this.itemsPerPage,
    );
  }

  // Computed properties
  bool get isLoading => status == LoadingStatus.loading;
  bool get hasError => status == LoadingStatus.error;
  bool get dateFilterActive => dateFilterStart != null && dateFilterEnd != null;

  /// Get filtered and sorted reports
  List<Report> get filteredReports {
    var filtered = List<Report>.from(allReports);

    // 1. Filter by Status
    if (selectedStatus != ReportStatusFilter.all) {
      filtered = filtered.where((report) {
        switch (selectedStatus) {
          case ReportStatusFilter.open:
            return report.status.toLowerCase() == 'open';
          case ReportStatusFilter.inProgress:
            return report.status.toLowerCase() == 'in_progress';
          case ReportStatusFilter.completed:
            return report.status.toLowerCase() == 'completed';
          case ReportStatusFilter.onHold:
            return report.status.toLowerCase() == 'on_hold';
          case ReportStatusFilter.all:
            return true;
        }
      }).toList();
    }

    // 2. Filter by Category (Report Type)
    if (selectedCategory != ReportCategoryFilter.all) {
      filtered = filtered.where((report) {
        switch (selectedCategory) {
          case ReportCategoryFilter.maintenanceIssue:
            return report.reportType.toLowerCase() == 'maintenance_issue';
          case ReportCategoryFilter.observation:
            return report.reportType.toLowerCase() == 'observation';
          case ReportCategoryFilter.safetyConcern:
            return report.reportType.toLowerCase() == 'safety_concern';
          case ReportCategoryFilter.all:
            return true;
        }
      }).toList();
    }

    // 3. Filter by Priority
    if (selectedPriority != ReportPriorityFilter.all) {
      filtered = filtered.where((report) {
        switch (selectedPriority) {
          case ReportPriorityFilter.low:
            return report.priority.toLowerCase() == 'low';
          case ReportPriorityFilter.medium:
            return report.priority.toLowerCase() == 'medium';
          case ReportPriorityFilter.high:
            return report.priority.toLowerCase() == 'high';
          case ReportPriorityFilter.all:
            return true;
        }
      }).toList();
    }

    // 4. Filter by Date Range
    if (dateFilterActive) {
      filtered = filtered.where((report) {
        return report.createdAt.isAfter(dateFilterStart!) &&
            report.createdAt.isBefore(dateFilterEnd!);
      }).toList();
    }

    // 5. Filter by Search Query
    if (searchQuery.isNotEmpty) {
      filtered = filtered.where((report) {
        return report.matchesSearchQuery(searchQuery);
      }).toList();
    }

    // 6. Apply Sorting
    if (sortColumn != null) {
      filtered = _sortReports(filtered, sortColumn!, sortAscending);
    }

    return filtered;
  }

  /// Get paginated reports for current page
  List<Report> get paginatedReports {
    final startIndex = (currentPage - 1) * itemsPerPage;
    final endIndex = startIndex + itemsPerPage;
    
    if (startIndex >= filteredReports.length) return [];
    
    return filteredReports.sublist(
      startIndex,
      endIndex > filteredReports.length ? filteredReports.length : endIndex,
    );
  }

  int get totalPages {
    if (filteredReports.isEmpty) return 1;
    return (filteredReports.length / itemsPerPage).ceil();
  }

  /// Sort reports based on column
  List<Report> _sortReports(List<Report> reports, String column, bool ascending) {
    final sorted = List<Report>.from(reports);

    switch (column) {
      case 'title':
        sorted.sort((a, b) => a.title.compareTo(b.title));
        break;
      case 'date':
        sorted.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      default:
        return sorted;
    }

    return ascending ? sorted : sorted.reversed.toList();
  }
}

// Extension helpers for display names
extension ReportStatusFilterExt on ReportStatusFilter {
  String get displayName {
    switch (this) {
      case ReportStatusFilter.all:
        return 'All';
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

extension ReportCategoryFilterExt on ReportCategoryFilter {
  String get displayName {
    switch (this) {
      case ReportCategoryFilter.all:
        return 'All';
      case ReportCategoryFilter.maintenanceIssue:
        return 'Maintenance Issue';
      case ReportCategoryFilter.observation:
        return 'Observation';
      case ReportCategoryFilter.safetyConcern:
        return 'Safety Concern';
    }
  }
}

extension ReportPriorityFilterExt on ReportPriorityFilter {
  String get displayName {
    switch (this) {
      case ReportPriorityFilter.all:
        return 'All';
      case ReportPriorityFilter.low:
        return 'Low';
      case ReportPriorityFilter.medium:
        return 'Medium';
      case ReportPriorityFilter.high:
        return 'High';
    }
  }
}