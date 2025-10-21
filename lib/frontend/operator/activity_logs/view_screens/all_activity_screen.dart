//all_activity_screen.dart
import 'package:flutter/material.dart';
import '../widgets/filter_section.dart';
import '../widgets/activity_card.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/date_filter_button.dart';
import '../models/activity_item.dart';
import '../../../../services/firestore_activity_service.dart';

class AllActivityScreen extends StatefulWidget {
  const AllActivityScreen({super.key});

  @override
  State<AllActivityScreen> createState() => _AllActivityScreenState();
}

class _AllActivityScreenState extends State<AllActivityScreen> {
  String selectedFilter = 'All';
  String searchQuery = '';
  bool isManualFilter = false;
  DateFilterRange _dateFilter = DateFilterRange(type: DateFilterType.none);
  final filters = const ['All', 'Substrate', 'Alerts'];
  final FocusNode _searchFocusNode = FocusNode();
  
  List<ActivityItem> _allActivities = [];
  bool _isLoggedIn = false;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _checkLoginAndLoadData();
  }

  Future<void> _checkLoginAndLoadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final userId = FirestoreActivityService.getCurrentUserId();
      _isLoggedIn = userId != null;
      
      if (_isLoggedIn) {
        // Upload mock data if needed, then load
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

  Future<void> _loadActivities() async {
    try {
      final activities = await FirestoreActivityService.getAllActivities();
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

  @override
  void dispose() {
    _searchFocusNode.dispose();
    super.dispose();
  }

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

  List<ActivityItem> get _dateFilteredActivities {
    if (!_dateFilter.isActive) {
      return _allActivities;
    }

    return _allActivities.where((item) {
      return item.timestamp.isAfter(_dateFilter.startDate!) &&
             item.timestamp.isBefore(_dateFilter.endDate!);
    }).toList();
  }

  List<ActivityItem> get _searchResults {
    if (searchQuery.isEmpty) {
      return _dateFilteredActivities;
    }
    return _dateFilteredActivities
        .where((item) => item.matchesSearchQuery(searchQuery))
        .toList();
  }

  Set<String> get _filterTypesInSearchResults {
    if (searchQuery.isEmpty) return {};
    
    final categories = _searchResults.map((item) => item.category).toSet();
    Set<String> filterTypes = {};

    bool hasSubstrate =
        categories.any((cat) => ['Greens', 'Browns', 'Compost'].contains(cat));
    bool hasAlerts = categories
        .any((cat) => ['Temp', 'Moisture', 'Oxygen'].contains(cat));

    if (hasSubstrate) {
      filterTypes.add('Substrate');
    }

    if (hasAlerts) {
      filterTypes.add('Alerts');
    }

    if (hasSubstrate && hasAlerts) {
      filterTypes.add('All');
    }

    return filterTypes;
  }

  List<ActivityItem> get _filteredActivities {
    List<ActivityItem> results = _searchResults;

    if (isManualFilter && selectedFilter != 'All') {
      if (selectedFilter == 'Substrate') {
        results = results.where((item) {
          return item.category == 'Greens' ||
              item.category == 'Browns' ||
              item.category == 'Compost';
        }).toList();
      } else if (selectedFilter == 'Alerts') {
        results = results.where((item) {
          return item.category == 'Temp' ||
              item.category == 'Moisture' ||
              item.category == 'Oxygen';
        }).toList();
      }
    }

    return results;
  }

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
          title: const Text("All Activity Logs", style: TextStyle(fontWeight: FontWeight.bold)),
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
                          filters: filters,
                          initialFilter: selectedFilter,
                          onSelected: _onFilterChanged,
                          autoHighlightedFilters: _filterTypesInSearchResults,
                        ),
                      ),
                      Expanded(
                        child: _buildContent(),
                      ),
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

  Widget _buildContent() {
    // Show loading indicator
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.teal),
      );
    }

    // Show login prompt
    if (!_isLoggedIn) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Text(
            'Please log in to view activity logs',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
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
              const Icon(
                Icons.error_outline,
                size: 48,
                color: Colors.grey,
              ),
              const SizedBox(height: 16),
              Text(
                'Error loading data',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
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
        child: Text(
          searchQuery.isNotEmpty
              ? 'No results found for "$searchQuery"'
              : 'No ${selectedFilter.toLowerCase()} activities found',
          style: const TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
          textAlign: TextAlign.center,
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