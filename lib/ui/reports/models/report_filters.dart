// lib/ui/reports/models/report_filters.dart

import '../../core/widgets/filters/mobile_dropdown_filter_button.dart';

/// Report status filter options
enum ReportStatusFilter implements FilterOption {
  all,
  open,
  inProgress,
  completed,
  onHold;

  @override
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

  @override
  bool get isAll => this == ReportStatusFilter.all;
}

/// Report category filter options
enum ReportCategoryFilter implements FilterOption {
  all,
  maintenance,
  observation,
  safety;

  @override
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

  @override
  bool get isAll => this == ReportCategoryFilter.all;
}

/// Report priority filter options
enum ReportPriorityFilter implements FilterOption {
  all,
  high,
  medium,
  low;

  @override
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

  @override
  bool get isAll => this == ReportPriorityFilter.all;
}