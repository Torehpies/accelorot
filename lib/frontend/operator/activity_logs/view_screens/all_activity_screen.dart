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
  
  late Future<List<ActivityItem>> _activitiesFuture;
  List<ActivityItem> _allActivities = [];

  @override
  void initState() {
    super.initState();
    _activitiesFuture = _loadActivities();
  }

  Future<List<ActivityItem>> _loadActivities() async {
    try {
      final activities = await FirestoreActivityService.getAllActivities();
      setState(() {
        _allActivities = activities;
      });
      return activities;
    } catch (e) {
      print('Error loading activities: $e');
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
  List<ActivityItem> get _dateFilteredActivities {
    if (!_dateFilter.isActive) {
      return _allActivities;
    }

    return _allActivities.where((item) {
      return item.timestamp.isAfter(_dateFilter.startDate!) &&
             item.timestamp.isBefore(_dateFilter.endDate!);
    }).toList();
  }

  // Get search results from date-filtered data
  List<ActivityItem> get _searchResults {
    if (searchQuery.isEmpty) {
      return _dateFilteredActivities;
    }
    return _dateFilteredActivities
        .where((item) => item.matchesSearchQuery(searchQuery))
        .toList();
  }

  // Get filter types present in search results
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

  // Filtered data based on selected filter
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
        body: FutureBuilder<List<ActivityItem>>(
          future: _activitiesFuture,
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
                              autoHighlightedFilters: _filterTypesInSearchResults,
                            ),
                          ),
                          Expanded(
                            child: _filteredActivities.isEmpty
                                ? Center(
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
                                  )
                                : ListView.builder(
                                    padding: const EdgeInsets.all(16),
                                    itemCount: _filteredActivities.length,
                                    itemBuilder: (context, index) {
                                      return ActivityCard(
                                          item: _filteredActivities[index]);
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