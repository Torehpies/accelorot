//alerts_screen.dart
import 'package:flutter/material.dart';
import '../widgets/filter_section.dart';
import '../widgets/activity_card.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/date_filter_button.dart';
import '../models/activity_item.dart';
import '../../../../services/firestore_activity_service.dart';

class AlertsScreen extends StatefulWidget {
  final String initialFilter;

  const AlertsScreen({
    super.key,
    this.initialFilter = 'All',
  });

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  late String selectedFilter;
  String searchQuery = '';
  bool isManualFilter = false;
  DateFilterRange _dateFilter = DateFilterRange(type: DateFilterType.none);
  final filters = const ['All', 'Temp', 'Moisture', 'Oxygen'];
  final FocusNode _searchFocusNode = FocusNode();
  
  late Future<List<ActivityItem>> _alertsFuture;
  List<ActivityItem> _allAlerts = [];

  @override
  void initState() {
    super.initState();
    selectedFilter = widget.initialFilter;
    if (widget.initialFilter != 'All') {
      isManualFilter = true;
    }
    
    // Load data from Firestore
    _alertsFuture = _loadAlerts();
  }

  Future<List<ActivityItem>> _loadAlerts() async {
    try {
      final alerts = await FirestoreActivityService.getAlerts();
      setState(() {
        _allAlerts = alerts;
      });
      return alerts;
    } catch (e) {
      print('Error loading alerts: $e');
      return [];
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

  // Apply date filter first
  List<ActivityItem> get _dateFilteredAlerts {
    if (!_dateFilter.isActive) {
      return _allAlerts;
    }

    return _allAlerts.where((item) {
      return item.timestamp.isAfter(_dateFilter.startDate!) &&
             item.timestamp.isBefore(_dateFilter.endDate!);
    }).toList();
  }

  // Get search results from date-filtered data
  List<ActivityItem> get _searchResults {
    if (searchQuery.isEmpty) {
      return _dateFilteredAlerts;
    }
    return _dateFilteredAlerts
        .where((item) => item.matchesSearchQuery(searchQuery))
        .toList();
  }

  // Get categories present in search results
  Set<String> get _categoriesInSearchResults {
    if (searchQuery.isEmpty) return {};
    
    final categories = _searchResults.map((item) => item.category).toSet();
    final specificCategories = {'Temp', 'Moisture', 'Oxygen'};
    final hasAllCategories =
        specificCategories.every((cat) => categories.contains(cat));

    Set<String> result = {};
    for (var cat in specificCategories) {
      if (categories.contains(cat)) {
        result.add(cat);
      }
    }

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
        _searchFocusNode.unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text("Alerts Logs", style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.teal,
          actions: [
            DateFilterButton(onFilterChanged: _onDateFilterChanged),
            const SizedBox(width: 8),
          ],
        ),
        body: FutureBuilder<List<ActivityItem>>(
          future: _alertsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Text('Error loading data: ${snapshot.error}'),
              );
            }

            return Padding(
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
                              autoHighlightedFilters: _categoriesInSearchResults,
                            ),
                          ),
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
                                    padding: const EdgeInsets.all(16),
                                    itemCount: _filteredAlerts.length,
                                    itemBuilder: (context, index) {
                                      return ActivityCard(
                                          item: _filteredAlerts[index]);
                                    },
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}