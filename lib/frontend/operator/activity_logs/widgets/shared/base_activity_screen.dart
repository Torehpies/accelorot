// lib/frontend/operator/activity_logs/widgets/shared/base_activity_screen.dart
import 'package:flutter/material.dart';
import '../../models/activity_item.dart';
import '../filter_section.dart';
import '../activity_card.dart';
import '../search_bar_widget.dart';
import '../date_filter_button.dart';
import '../../../../../services/firestore_activity_service.dart';

/// Abstract base class for all activity log screens
/// Provides common functionality: search, filters, date filtering, data loading, and UI
abstract class BaseActivityScreen extends StatefulWidget {
  final String? initialFilter;
  final String? viewingOperatorId;
  final String? focusedMachineId;

  const BaseActivityScreen({
    super.key,
    this.initialFilter,
    this.viewingOperatorId,
    this.focusedMachineId,
  });

  @override
  State<BaseActivityScreen> createState();
}

/// Base state class containing all shared logic
/// Child classes must implement abstract methods for screen-specific behavior
abstract class BaseActivityScreenState<T extends BaseActivityScreen>
    extends State<T> {
  // ===== ABSTRACT METHODS - Must be implemented by child classes =====

  /// AppBar title text
  String get screenTitle;

  /// List of filter chip labels (e.g., ['All', 'Temp', 'Moisture', 'Oxygen'])
  List<String> get filters;

  /// Fetch data from Firestore
  Future<List<ActivityItem>> fetchData();

  /// Filter items by selected category
  /// @param items - List of all items
  /// @param filter - Selected filter string
  /// @return Filtered list of items
  List<ActivityItem> filterByCategory(List<ActivityItem> items, String filter);

  /// Determine which filters to auto-highlight during search
  /// @param searchResults - Filtered list from search
  /// @return Set of filter labels to highlight
  Set<String> getCategoriesInSearchResults(List<ActivityItem> searchResults);

  // ===== SHARED STATE VARIABLES =====

  // Filter state
  late String selectedFilter;
  String searchQuery = '';
  bool isManualFilter = false;
  DateFilterRange _dateFilter = DateFilterRange(type: DateFilterType.none);

  // UI state
  final FocusNode _searchFocusNode = FocusNode();

  // Data state
  List<ActivityItem> _allActivities = [];
  bool _isLoggedIn = false;
  bool _isLoading = true;
  String? _errorMessage;

  // ===== LIFECYCLE METHODS =====

  @override
  void initState() {
    super.initState();
    selectedFilter = widget.initialFilter ?? 'All';
    if (widget.initialFilter != null && widget.initialFilter != 'All') {
      isManualFilter = true;
    }
    _checkLoginAndLoadData();
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    super.dispose();
  }

  // ===== DATA LOADING METHODS =====

  /// Check authentication and load data
  Future<void> _checkLoginAndLoadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final effectiveUserId =
          widget.viewingOperatorId ??
          FirestoreActivityService.getEffectiveUserId();
      _isLoggedIn = effectiveUserId.isNotEmpty;

      if (_isLoggedIn) {
        await FirestoreActivityService.uploadAllMockData();
        await _loadActivities();
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Load activities using child's fetchData implementation
  Future<void> _loadActivities() async {
    try {
      List<ActivityItem> activities =
          await fetchData(); // Calls child's implementation

      // Filter by machine if focusedMachineId is provided
      if (widget.focusedMachineId != null) {
        activities = activities
            .where((item) => item.machineId == widget.focusedMachineId)
            .toList();
      }

      if (mounted) {
        setState(() {
          _allActivities = activities;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
        });
      }
    }
  }

  // ===== EVENT HANDLERS =====

  void _onFilterChanged(String filter) {
    setState(() {
      selectedFilter = filter;
      isManualFilter = true;
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      searchQuery = query.toLowerCase();
    });
  }

  void _onSearchCleared() {
    setState(() {
      searchQuery = '';
    });
  }

  void _onDateFilterChanged(DateFilterRange filter) {
    setState(() {
      _dateFilter = filter;
    });
  }

  // ===== COMPUTED PROPERTIES =====

  /// Apply date filter to all activities
  List<ActivityItem> get _dateFilteredActivities {
    if (!_dateFilter.isActive) {
      return _allActivities;
    }

    return _allActivities.where((item) {
      return item.timestamp.isAfter(_dateFilter.startDate!) &&
          item.timestamp.isBefore(_dateFilter.endDate!);
    }).toList();
  }

  /// Apply search query to date-filtered activities
  List<ActivityItem> get _searchResults {
    if (searchQuery.isEmpty) {
      return _dateFilteredActivities;
    }
    return _dateFilteredActivities
        .where((item) => item.matchesSearchQuery(searchQuery))
        .toList();
  }

  /// Get filters to auto-highlight based on search results
  Set<String> get _categoriesInSearchResults {
    if (searchQuery.isEmpty) return {};
    return getCategoriesInSearchResults(
      _searchResults,
    ); // Calls child's implementation
  }

  /// Apply category filter to search results
  List<ActivityItem> get _filteredActivities {
    if (isManualFilter && selectedFilter != 'All') {
      return filterByCategory(
        _searchResults,
        selectedFilter,
      ); // Calls child's implementation
    }

    if (selectedFilter == 'All' || !isManualFilter) {
      return _searchResults;
    }

    return filterByCategory(
      _searchResults,
      selectedFilter,
    ); // Calls child's implementation
  }

  // ===== UI BUILD METHODS =====

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _searchFocusNode.unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                screenTitle, // Uses child's implementation
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              // Show subtitle when in machine view
              if (widget.focusedMachineId != null)
                Text(
                  'Machine ID: ${widget.focusedMachineId}',
                  style: const TextStyle(fontSize: 12, color: Colors.white70),
                ),
            ],
          ),
          backgroundColor: Colors.teal,
          actions: [
            DateFilterButton(onFilterChanged: _onDateFilterChanged),
            const SizedBox(width: 8),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Column(
            children: [
              // Show machine filter banner
              if (widget.focusedMachineId != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.teal.shade50, Colors.teal.shade100],
                    ),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.teal.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.filter_alt,
                        color: Colors.teal.shade700,
                        size: 18,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Showing activities for this machine only',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.teal.shade900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              SearchBarWidget(
                onSearchChanged: _onSearchChanged,
                onClear: _onSearchCleared,
                focusNode: _searchFocusNode,
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                    border: Border.all(color: Colors.grey[300]!, width: 1.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                        child: FilterSection(
                          filters: filters, // Uses child's implementation
                          initialFilter: selectedFilter,
                          onSelected: _onFilterChanged,
                          autoHighlightedFilters: _categoriesInSearchResults,
                        ),
                      ),
                      Expanded(child: _buildContent()),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build content based on current state (loading, error, empty, list)
  Widget _buildContent() {
    // Show loading indicator
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Colors.teal));
    }

    // Show login prompt
    if (!_isLoggedIn) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Text(
            'Please log in to view activity logs',
            style: TextStyle(fontSize: 16, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    // Show error message
    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.grey),
              const SizedBox(height: 16),
              const Text(
                'Error loading data',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _checkLoginAndLoadData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    // Show empty state
    if (_filteredActivities.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                widget.focusedMachineId != null
                    ? 'No activities found for this machine'
                    : searchQuery.isNotEmpty
                    ? 'No results found for "$searchQuery"'
                    : 'No ${selectedFilter.toLowerCase()} activities found',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              if (widget.focusedMachineId != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Activities will appear here once waste is added to this machine',
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      );
    }

    // Show list
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredActivities.length,
      itemBuilder: (context, index) {
        return ActivityCard(item: _filteredActivities[index]);
      },
    );
  }
}
