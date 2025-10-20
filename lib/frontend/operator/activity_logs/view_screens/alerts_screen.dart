//alerts_screen.dart
import 'package:flutter/material.dart';
import '../widgets/filter_section.dart';
import '../widgets/activity_card.dart';
import '../widgets/search_bar_widget.dart';
import '../models/activity_item.dart';
import '../services/mock_data_service.dart';

class AlertsScreen extends StatefulWidget {
  final String initialFilter;

  const AlertsScreen({super.key, this.initialFilter = 'All'});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  late String selectedFilter;
  String searchQuery = '';
  bool isManualFilter = false;
  final filters = const ['All', 'Temp', 'Moisture', 'Oxygen'];
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    selectedFilter = widget.initialFilter;
    // If initialFilter is not 'All', treat it as manual selection
    if (widget.initialFilter != 'All') {
      isManualFilter = true;
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
      // Keep the manually selected filter, don't reset to 'All'
      // If no manual filter was set, selectedFilter stays 'All'
    });
  }

  // Get search results
  List<ActivityItem> get _searchResults {
    final alerts = MockDataService.getAlerts();
    if (searchQuery.isEmpty) {
      return alerts;
    }
    return alerts
        .where((item) => item.matchesSearchQuery(searchQuery))
        .toList();
  }

  // Get categories present in search results
  Set<String> get _categoriesInSearchResults {
    if (searchQuery.isEmpty) return {};

    final categories = _searchResults.map((item) => item.category).toSet();

    // Define the specific categories (excluding 'All')
    final specificCategories = {'Temp', 'Moisture', 'Oxygen'};

    // Check if ALL specific categories have matches
    final hasAllCategories = specificCategories.every(
      (cat) => categories.contains(cat),
    );

    Set<String> result = {};

    // Add specific categories that have matches
    for (var cat in specificCategories) {
      if (categories.contains(cat)) {
        result.add(cat);
      }
    }

    // Only add 'All' if ALL categories have matches
    if (hasAllCategories) {
      result.add('All');
    }

    return result;
  }

  // Filtered list based on selected filter
  List<ActivityItem> get _filteredAlerts {
    if (isManualFilter && selectedFilter != 'All') {
      return _searchResults
          .where((item) => item.category == selectedFilter)
          .toList();
    }

    if (selectedFilter == 'All' || !isManualFilter) {
      return _searchResults;
    }

    return _searchResults
        .where((item) => item.category == selectedFilter)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Unfocus search bar when tapping anywhere on screen
        _searchFocusNode.unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text(
            "Alerts Logs",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.teal,
        ),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Column(
            children: [
              // Search Bar
              SearchBarWidget(
                onSearchChanged: _onSearchChanged,
                onClear: _onSearchCleared,
                focusNode: _searchFocusNode,
              ),
              const SizedBox(height: 12),

              // White Container with filters and cards
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
                      // Fixed filter section at top
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                        child: FilterSection(
                          filters: filters,
                          initialFilter: selectedFilter,
                          onSelected: _onFilterChanged,
                          autoHighlightedFilters: _categoriesInSearchResults,
                        ),
                      ),

                      // Scrollable cards list
                      Expanded(
                        child: _filteredAlerts.isEmpty
                            ? Center(
                                child: Text(
                                  searchQuery.isNotEmpty
                                      ? 'No results found for "$searchQuery"'
                                      : 'No ${selectedFilter.toLowerCase()} alerts found',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                                itemCount: _filteredAlerts.length,
                                itemBuilder: (context, index) {
                                  return ActivityCard(
                                    item: _filteredAlerts[index],
                                  );
                                },
                              ),
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
}
