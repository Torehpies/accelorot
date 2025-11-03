// lib/frontend/operator/machine_management/reports/controllers/reports_controller.dart

import 'package:flutter/material.dart';
import '../models/report_model.dart';
import '../../../../../../services/report_services/firestore_report_service.dart';

enum SortOption {
  newest,
  oldest,
  priorityHighToLow,
}

class ReportsController extends ChangeNotifier {
  // ==================== STATE ====================
  
  List<ReportModel> _allReports = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';
  String _selectedFilter = 'All'; // All, Open, In Progress, Closed
  SortOption _sortOption = SortOption.newest;
  bool _isAuthenticated = false;
  int _displayLimit = 10;
  static const int _pageSize = 10;

  // ⭐ Search controller for external control
  final TextEditingController searchController = TextEditingController();

  // ==================== GETTERS ====================
  
  List<ReportModel> get allReports => _allReports;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  String get selectedFilter => _selectedFilter;
  SortOption get sortOption => _sortOption;
  bool get isAuthenticated => _isAuthenticated;

  /// Get filtered and sorted reports
  List<ReportModel> get filteredReports {
    var filtered = List<ReportModel>.from(_allReports);

    // Apply filter chips
    if (_selectedFilter != 'All') {
      final filterLower = _selectedFilter.toLowerCase();
      filtered = filtered.where((report) {
        final statusLower = report.status.toLowerCase();
        
        // Map filter to status
        if (filterLower == 'open') return statusLower == 'open';
        if (filterLower == 'in progress') return statusLower == 'in_progress';
        if (filterLower == 'closed') return statusLower == 'closed';
        
        return true;
      }).toList();
    }

    // Apply search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((report) {
        return report.matchesSearchQuery(_searchQuery);
      }).toList();
    }

    // Apply sorting
    switch (_sortOption) {
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

  /// Get reports to display with pagination
  List<ReportModel> get displayedReports {
    return filteredReports.take(_displayLimit).toList();
  }

  /// Check if there are more reports to load
  bool get hasMoreToLoad {
    return displayedReports.length < filteredReports.length;
  }

  /// Get count of remaining reports
  int get remainingCount {
    return filteredReports.length - displayedReports.length;
  }

  /// Get auto-highlighted filters based on search results
  Set<String> get autoHighlightedFilters {
    if (_searchQuery.isEmpty) return {};
    
    final Set<String> highlights = {};
    final results = filteredReports;
    
    for (var report in results) {
      final statusLower = report.status.toLowerCase();
      if (statusLower == 'open') highlights.add('Open');
      if (statusLower == 'in_progress') highlights.add('In Progress');
      if (statusLower == 'closed') highlights.add('Closed');
    }
    
    return highlights;
  }

  // ==================== INITIALIZATION ====================
  
  Future<void> initialize() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final currentUserId = FirestoreReportService.getCurrentUserId();
      _isAuthenticated = currentUserId != null;

      if (_isAuthenticated) {
        // Fetch reports for the user's team
        await _fetchTeamReports(currentUserId!);
      } else {
        // Not authenticated - empty reports
        _allReports = [];
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load reports: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  // ==================== FETCH OPERATIONS ====================
  
  Future<void> _fetchTeamReports(String teamId) async {
    try {
      _allReports = await FirestoreReportService.getTeamReports(teamId);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to fetch reports: $e';
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    final currentUserId = FirestoreReportService.getCurrentUserId();
    _isAuthenticated = currentUserId != null;
    
    if (_isAuthenticated) {
      await _fetchTeamReports(currentUserId!);
    } else {
      _allReports = [];
      notifyListeners();
    }
  }

  // ==================== UI STATE MANAGEMENT ====================
  
  void setSearchQuery(String query) {
    _searchQuery = query;
    resetPagination();
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    searchController.clear();
    resetPagination();
    notifyListeners();
  }

  void setFilter(String filter) {
    _selectedFilter = filter;
    resetPagination();
    notifyListeners();
  }

  void setSortOption(SortOption option) {
    _sortOption = option;
    notifyListeners();
  }

  // ==================== PAGINATION ====================
  
  void loadMore() {
    _displayLimit += _pageSize;
    notifyListeners();
  }

  void resetPagination() {
    _displayLimit = _pageSize;
  }

  // ==================== UPDATE OPERATIONS ====================
  
  /// Update an existing report
  Future<void> updateReport({
    required String machineId,
    required String reportId,
    String? title,
    String? description,
    String? status,
    String? priority,
  }) async {
    try {
      if (!_isAuthenticated) {
        throw Exception('You must be logged in to update reports');
      }

      await FirestoreReportService.updateReport(
        machineId: machineId,
        reportId: reportId,
        title: title,
        description: description,
        status: status,
        priority: priority,
      );

      // Delay before refresh (like machines)
      await Future.delayed(const Duration(milliseconds: 1000));
      await refresh();
    } catch (e) {
      _errorMessage = 'Failed to update report: $e';
      notifyListeners();
      rethrow;
    }
  }

  // ==================== HELPER METHODS ====================
  
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}