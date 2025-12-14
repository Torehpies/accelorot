// lib/ui/activity_logs/services/activity_filter_service.dart

import '../../../data/models/activity_log_item.dart';
import '../models/activity_list_state.dart';
import '../models/activity_filter_config.dart';

class ActivityFilterService {
  /// Apply all filters: date, search, category
  FilterResult applyAllFilters({
    required List<ActivityLogItem> items,
    required String selectedFilter,
    required String searchQuery,
    required DateFilterRange dateFilter,
    required ActivityFilterConfig config,
    required bool isManualFilter,
    String? selectedBatchId,
    String? selectedMachineId,
  }) {

    var filtered = applyMachineFilter(items, selectedMachineId);

    filtered = applyBatchFilter(filtered, selectedBatchId);

    // Step 1: Apply date filter
    filtered = applyDateFilter(filtered, dateFilter);

    // Step 2: Apply search filter
    filtered = applySearchFilter(filtered, searchQuery);

    

    // Step 3: Compute auto-highlighted filters based on search results
    final highlighted = computeHighlightedFilters(
      searchResults: filtered,
      searchQuery: searchQuery,
      config: config,
    );

    // Step 4: Apply category filter (only if manually selected)
    filtered = applyCategoryFilter(
      items: filtered,
      selectedFilter: selectedFilter,
      isManualFilter: isManualFilter,
      config: config,
    );

    return FilterResult(
      filteredItems: filtered,
      highlightedFilters: highlighted,
    );
  }

  /// Filter activities by date range
  List<ActivityLogItem> applyDateFilter(
    List<ActivityLogItem> items,
    DateFilterRange dateFilter,
  ) {
    if (!dateFilter.isActive) return items;

    return items.where((item) {
      return item.timestamp.isAfter(dateFilter.startDate!) &&
          item.timestamp.isBefore(dateFilter.endDate!);
    }).toList();
  }

  /// Filter activities by search query
  /// 
  /// Searches across multiple fields: title, value, description,
  /// category, machine name, operator name, batch ID, status
  List<ActivityLogItem> applySearchFilter(
    List<ActivityLogItem> items,
    String searchQuery,
  ) {
    if (searchQuery.isEmpty) return items;

    final query = searchQuery.toLowerCase();
    return items
        .where((item) => item.matchesSearchQuery(query))
        .toList();
  }

  List<ActivityLogItem> applyBatchFilter(
    List<ActivityLogItem> items,
    String? selectedBatchId,
  ) {
    if (selectedBatchId == null || selectedBatchId.isEmpty) return items;
    return items.where((item) => item.batchId == selectedBatchId).toList();
  }

  List<ActivityLogItem> applyMachineFilter(
    List<ActivityLogItem> items,
    String? selectedMachineId,
  ) {
    if (selectedMachineId == null || selectedMachineId.isEmpty) return items;
    return items.where((item) => item.machineId == selectedMachineId).toList();
  }

  /// Compute which filter chips should be highlighted based on search results
  /// 
  /// When a user searches, this determines which category filters
  /// contain matching results (for visual feedback)
  Set<String> computeHighlightedFilters({
    required List<ActivityLogItem> searchResults,
    required String searchQuery,
    required ActivityFilterConfig config,
  }) {
    // Only highlight filters when actively searching
    if (searchQuery.isEmpty) return {};

    final categories = searchResults.map((item) => item.category).toSet();
    return config.categoryHighlighter(categories, config.filters);
  }

  /// Filter activities by category
  /// 
  /// Only applies when user has manually selected a filter
  /// (not 'All' and isManualFilter is true)
  List<ActivityLogItem> applyCategoryFilter({
    required List<ActivityLogItem> items,
    required String selectedFilter,
    required bool isManualFilter,
    required ActivityFilterConfig config,
  }) {
    // If manual filter is set and not 'All', apply category filter
    if (isManualFilter && selectedFilter != 'All') {
      return config.categoryMapper<ActivityLogItem>(
        items,
        selectedFilter,
        (item) => item.category,
      );
    }

    // If 'All' or no manual filter, show all (already filtered by search/date)
    return items;
  }
}

/// Result object containing filtered items and highlighted filters
class FilterResult {
  final List<ActivityLogItem> filteredItems;
  final Set<String> highlightedFilters;

  const FilterResult({
    required this.filteredItems,
    required this.highlightedFilters,
  });
}