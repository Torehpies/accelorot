// lib/ui/reports/models/mobile_reports_state.dart

import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../data/models/report.dart';
import '../../activity_logs/models/activity_common.dart';
import '../services/report_filter_service.dart';
import 'report_filters.dart';

part 'mobile_reports_state.freezed.dart';

/// State for mobile reports management
@freezed
abstract class MobileReportsState with _$MobileReportsState {
  const factory MobileReportsState({
    @Default(ReportStatusFilter.all) ReportStatusFilter selectedStatus,
    @Default(ReportCategoryFilter.all) ReportCategoryFilter selectedCategory,
    @Default(ReportPriorityFilter.all) ReportPriorityFilter selectedPriority,
    @Default(DateFilterRange(type: DateFilterType.none)) DateFilterRange dateFilter,
    @Default('') String searchQuery,
    @Default('date') String selectedSort,
    @Default([]) List<Report> reports,
    @Default(5) int displayLimit,
    @Default(LoadingStatus.initial) LoadingStatus status,
    String? errorMessage,
  }) = _MobileReportsState;

  const MobileReportsState._();

  bool get isLoading => status == LoadingStatus.loading;
  bool get hasError => status == LoadingStatus.error;

  List<Report> get filteredReports {
    final filterService = ReportFilterService();
    
    final result = filterService.applyAllFilters(
      reports: reports,
      dateFilter: dateFilter,
      searchQuery: searchQuery,
      selectedStatus: selectedStatus,
      selectedCategory: selectedCategory,
      selectedPriority: selectedPriority,
      sortColumn: selectedSort,
      sortAscending: false,
    );
    
    return result.filteredReports;
  }

  List<Report> get displayedReports {
    if (filteredReports.length <= displayLimit) {
      return filteredReports;
    }
    return filteredReports.sublist(0, displayLimit);
  }

  bool get hasMoreToLoad => filteredReports.length > displayLimit;
  
  int get remainingCount => filteredReports.length - displayLimit;

  bool get hasActiveFilters {
    return selectedStatus != ReportStatusFilter.all ||
        selectedCategory != ReportCategoryFilter.all ||
        selectedPriority != ReportPriorityFilter.all ||
        dateFilter.isActive ||
        searchQuery.isNotEmpty;
  }
}