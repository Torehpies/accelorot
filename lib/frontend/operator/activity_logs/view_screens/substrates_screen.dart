//substrates_screen.dart
import 'package:flutter/material.dart';
import '../widgets/filter_section.dart';
import '../widgets/activity_card.dart';
import '../widgets/search_bar_widget.dart';
import '../models/activity_item.dart';
import '../services/mock_data_service.dart';

class SubstratesScreen extends StatefulWidget {
  final String initialFilter;

  const SubstratesScreen({
    super.key,
    this.initialFilter = 'All',
  });

  @override
  State<SubstratesScreen> createState() => _SubstratesScreenState();
}

class _SubstratesScreenState extends State<SubstratesScreen> {
  late String selectedFilter;
  String searchQuery = '';
  bool isManualFilter = false;
  final filters = const ['All', 'Greens', 'Browns', 'Compost'];

  @override
  void initState() {
    super.initState();
    selectedFilter = widget.initialFilter;
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
    final substrates = MockDataService.getSubstrates();
    if (searchQuery.isEmpty) {
      return substrates;
    }
    return substrates.where((item) {
      return item.title.toLowerCase().contains(searchQuery) ||
             item.description.toLowerCase().contains(searchQuery);
    }).toList();
  }

  // Get categories present in search results
  Set<String> get _categoriesInSearchResults {
    if (searchQuery.isEmpty) return {};
    final categories = _searchResults.map((item) => item.category).toSet();
    categories.remove('All'); // Don't auto-highlight 'All'
    return categories;
  }

  // Filtered list based on selected filter
  List<ActivityItem> get _filteredSubstrates {
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
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text("Substrate Logs"),
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
                        autoHighlightedFilters: _categoriesInSearchResults,
                      ),
                    ),

                    // Scrollable cards list
                    Expanded(
                      child: _filteredSubstrates.isEmpty
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
                              itemCount: _filteredSubstrates.length,
                              itemBuilder: (context, index) {
                                return ActivityCard(
                                    item: _filteredSubstrates[index]);
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