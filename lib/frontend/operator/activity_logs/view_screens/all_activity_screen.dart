//all_activity_screen.dart
import 'package:flutter/material.dart';
import '../widgets/filter_section.dart';
import '../widgets/activity_card.dart';
import '../widgets/search_bar_widget.dart';
import '../models/activity_item.dart';
import '../services/mock_data_service.dart';

class AllActivityScreen extends StatefulWidget {
  const AllActivityScreen({super.key});

  @override
  State<AllActivityScreen> createState() => _AllActivityScreenState();
}

class _AllActivityScreenState extends State<AllActivityScreen> {
  String selectedFilter = 'All';
  String searchQuery = '';
  bool isManualFilter = false;
  final filters = const ['All', 'Substrate', 'Alerts'];

  void _onFilterChanged(String filter) {
    setState(() {
      selectedFilter = filter;
      isManualFilter = true;
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      searchQuery = query.toLowerCase();
      if (query.isEmpty) {
        isManualFilter = false;
        selectedFilter = 'All';
      }
    });
  }

  void _onSearchCleared() {
    setState(() {
      searchQuery = '';
      isManualFilter = false;
      selectedFilter = 'All';
    });
  }

  // Get search results
  List<ActivityItem> get _searchResults {
    final allActivities = MockDataService.getAllActivities();
    if (searchQuery.isEmpty) {
      return allActivities;
    }
    return allActivities.where((item) {
      return item.title.toLowerCase().contains(searchQuery) ||
             item.description.toLowerCase().contains(searchQuery);
    }).toList();
  }

  // Get filter types present in search results (Substrate or Alerts)
  Set<String> get _filterTypesInSearchResults {
    if (searchQuery.isEmpty) return {};
    
    final categories = _searchResults.map((item) => item.category).toSet();
    Set<String> filterTypes = {};
    
    // Check if any substrate categories exist
    if (categories.any((cat) => ['Greens', 'Browns', 'Compost'].contains(cat))) {
      filterTypes.add('Substrate');
    }
    
    // Check if any alert categories exist
    if (categories.any((cat) => ['Temp', 'Moisture', 'Humidity'].contains(cat))) {
      filterTypes.add('Alerts');
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
                 item.category == 'Humidity';
        }).toList();
      }
    }
    
    return results;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text("All Activity Logs"),
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
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                      child: FilterSection(
                        filters: filters,
                        initialFilter: selectedFilter,
                        onSelected: _onFilterChanged,
                        autoHighlightedFilters: _filterTypesInSearchResults,
                      ),
                    ),

                    // Scrollable cards list
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
      ),
    );
  }
}