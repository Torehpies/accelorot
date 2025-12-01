import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../data/models/report_model.dart';
import '../../../data/repositories/report_repository.dart';
import '../../../data/providers/report_providers.dart';
import '../../../services/sess_service.dart';

part 'reports_notifier.g.dart';

enum SortOption { newest, oldest, priorityHighToLow }

class ReportsState {
  final List<ReportModel> reports;
  final bool isLoading;
  final String? errorMessage;
  final String searchQuery;
  final String selectedFilter;
  final SortOption sortOption;
  final int displayLimit;

  const ReportsState({
    this.reports = const [],
    this.isLoading = false,
    this.errorMessage,
    this.searchQuery = '',
    this.selectedFilter = 'All',
    this.sortOption = SortOption.newest,
    this.displayLimit = 10,
  });

  ReportsState copyWith({
    List<ReportModel>? reports,
    bool? isLoading,
    String? errorMessage,
    String? searchQuery,
    String? selectedFilter,
    SortOption? sortOption,
    int? displayLimit,
  }) {
    return ReportsState(
      reports: reports ?? this.reports,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      sortOption: sortOption ?? this.sortOption,
      displayLimit: displayLimit ?? this.displayLimit,
    );
  }

  List<ReportModel> get filteredReports {
    var filtered = List<ReportModel>.from(reports);

    // Apply filter chips
    if (selectedFilter != 'All') {
      final filterLower = selectedFilter.toLowerCase();
      filtered = filtered.where((report) {
        final statusLower = report.status.toLowerCase();
        if (filterLower == 'open') return statusLower == 'open';
        if (filterLower == 'in progress') return statusLower == 'in_progress';
        if (filterLower == 'closed') return statusLower == 'closed';
        return true;
      }).toList();
    }

    // Apply search query
    if (searchQuery.isNotEmpty) {
      filtered = filtered.where((report) {
        return report.matchesSearchQuery(searchQuery);
      }).toList();
    }

    // Apply sorting
    switch (sortOption) {
      case SortOption.newest:
        filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case SortOption.oldest:
        filtered.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case SortOption.priorityHighToLow:
        filtered.sort((a, b) {
          final priorityOrder = {'high': 0, 'medium': 1, 'low': 2};
          final priorityA = priorityOrder[a.priority.toLowerCase()] ?? 3;
          final priorityB = priorityOrder[b.priority.toLowerCase()] ?? 3;
          return priorityA.compareTo(priorityB);
        });
        break;
    }

    return filtered;
  }

  List<ReportModel> get displayedReports {
    return filteredReports.take(displayLimit).toList();
  }

  bool get hasMoreToLoad {
    return displayedReports.length < filteredReports.length;
  }

  int get remainingCount {
    return filteredReports.length - displayedReports.length;
  }

  Set<String> get autoHighlightedFilters {
    if (searchQuery.isEmpty) return {};

    final Set<String> highlights = {};
    for (var report in filteredReports) {
      final statusLower = report.status.toLowerCase();
      if (statusLower == 'open') highlights.add('Open');
      if (statusLower == 'in_progress') highlights.add('In Progress');
      if (statusLower == 'closed') highlights.add('Closed');
    }
    return highlights;
  }
}

@riverpod
class ReportsNotifier extends _$ReportsNotifier {
  static const int _pageSize = 10;
  
  ReportRepository get _repository => ref.read(reportRepositoryProvider);

  @override
  ReportsState build() {
    return const ReportsState();
  }

  Future<void> initialize(String teamId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final reports = await _repository.getReportsByTeam(teamId);
      state = state.copyWith(reports: reports, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Failed to load reports: ${e.toString()}',
        isLoading: false,
      );
    }
  }

  Future<void> refresh(String teamId) async {
    try {
      final reports = await _repository.getReportsByTeam(teamId);
      state = state.copyWith(reports: reports);
    } catch (e) {
      state = state.copyWith(errorMessage: 'Failed to refresh: $e');
    }
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query, displayLimit: _pageSize);
  }

  void clearSearch() {
    state = state.copyWith(searchQuery: '', displayLimit: _pageSize);
  }

  void setFilter(String filter) {
    state = state.copyWith(selectedFilter: filter, displayLimit: _pageSize);
  }

  void setSortOption(SortOption option) {
    state = state.copyWith(sortOption: option);
  }

  void loadMore() {
    state = state.copyWith(displayLimit: state.displayLimit + _pageSize);
  }

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
      
      // Get teamId and refresh
      final sessionService = SessionService();
      final userData = await sessionService.getCurrentUserData();
      final teamId = userData?['teamId'] as String?;
      
      if (teamId != null) {
        await Future.delayed(const Duration(milliseconds: 1000));
        await refresh(teamId);
      }
    } catch (e) {
      state = state.copyWith(errorMessage: 'Failed to update report: $e');
      rethrow;
    }
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}