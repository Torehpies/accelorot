import 'package:flutter/material.dart';
import '../../themes/app_theme.dart';

/// A reusable container widget that displays a list of cards with search and filter capabilities
class FilterableCardListContainer extends StatefulWidget {
  /// List of filter options to display as chips/tabs
  final List<String> filters;

  /// Currently selected filter
  final String selectedFilter;

  /// Callback when filter is changed
  final ValueChanged<String> onFilterChanged;

  /// Search query text
  final String? searchQuery;

  /// Callback when search query changes
  final ValueChanged<String>? onSearchChanged;

  /// List of widgets (cards) to display
  final List<Widget> cards;

  /// Show search bar
  final bool showSearch;

  /// Show filter chips
  final bool showFilters;

  /// Placeholder text for search field
  final String searchHint;

  /// Widget to display when cards list is empty
  final Widget? emptyState;

  /// Whether data is loading
  final bool isLoading;

  /// Background color of the container
  final Color? backgroundColor;

  /// Padding around the container content
  final EdgeInsetsGeometry? padding;

  /// Custom color mapping for filters (filter name -> color)
  /// If not provided, uses default green color for selected filter
  final Map<String, Color>? filterColors;

  const FilterableCardListContainer({
    super.key,
    required this.filters,
    required this.selectedFilter,
    required this.onFilterChanged,
    required this.cards,
    this.searchQuery,
    this.onSearchChanged,
    this.showSearch = true,
    this.showFilters = true,
    this.searchHint = 'Search...',
    this.emptyState,
    this.isLoading = false,
    this.backgroundColor,
    this.padding,
    this.filterColors,
  });

  @override
  State<FilterableCardListContainer> createState() =>
      _FilterableCardListContainerState();
}

class _FilterableCardListContainerState
    extends State<FilterableCardListContainer> {
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.searchQuery);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(FilterableCardListContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.searchQuery != oldWidget.searchQuery) {
      _searchController.text = widget.searchQuery ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: widget.backgroundColor ?? AppColors.background,
      child: Column(
        children: [
          // Search and filters section
          Container(
            padding:
                widget.padding ??
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: widget.backgroundColor ?? AppColors.background,
            child: Column(
              children: [
                // Search bar
                if (widget.showSearch) ...[
                  _buildSearchBar(),
                  const SizedBox(height: 12),
                ],

                // Filter chips
                if (widget.showFilters) _buildFilterChips(),
              ],
            ),
          ),

          // Cards list
          Expanded(
            child: widget.isLoading
                ? _buildLoadingState()
                : widget.cards.isEmpty
                ? _buildEmptyState()
                : _buildCardsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0x4DD1DBE0), // AppColors.grey at 30% opacity
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000), // Black at 5% opacity
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: widget.onSearchChanged,
        decoration: InputDecoration(
          hintText: widget.searchHint,
          hintStyle: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: AppColors.textSecondary,
            size: 20,
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          isDense: true,
        ),
        style: TextStyle(color: AppColors.textPrimary, fontSize: 14),
      ),
    );
  }

  Widget _buildFilterChips() {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: widget.filters.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = widget.filters[index];
          final isSelected = filter == widget.selectedFilter;

          // Get color for this filter
          Color selectedColor = AppColors.green100;
          if (widget.filterColors != null &&
              widget.filterColors!.containsKey(filter)) {
            selectedColor = widget.filterColors![filter]!;
          }

          return _buildFilterChip(
            label: filter,
            isSelected: isSelected,
            selectedColor: selectedColor,
            onTap: () => widget.onFilterChanged(filter),
          );
        },
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required Color selectedColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? selectedColor : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? selectedColor
                : const Color(0x4DD1DBE0), // AppColors.grey at 30% opacity
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: selectedColor.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : const [
                  BoxShadow(
                    color: Color(0x0D000000), // Black at 5% opacity
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected)
              Padding(
                padding: const EdgeInsets.only(right: 6),
                child: Icon(Icons.check, color: Colors.white, size: 16),
              ),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.textPrimary,
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardsList() {
    return ListView.builder(
      padding:
          widget.padding ??
          const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: widget.cards.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: widget.cards[index],
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return Center(child: CircularProgressIndicator(color: AppColors.green100));
  }

  Widget _buildEmptyState() {
    if (widget.emptyState != null) {
      return widget.emptyState!;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.inbox_outlined,
            size: 64,
            color: Color(0x80374151), // AppColors.textSecondary at 50% opacity
          ),
          const SizedBox(height: 16),
          const Text(
            'No items found',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Try adjusting your search or filters',
            style: TextStyle(
              color: Color(
                0xB36B7280,
              ), // AppColors.textSecondary at 70% opacity
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
