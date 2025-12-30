//filter_section.dart
import 'package:flutter/material.dart';

class FilterSection extends StatefulWidget {
  final List<String> filters;
  final ValueChanged<String> onSelected;
  final String initialFilter;
  final Set<String>
  autoHighlightedFilters; // Filters to auto-highlight from search

  const FilterSection({
    super.key,
    required this.filters,
    required this.onSelected,
    this.initialFilter = 'All',
    this.autoHighlightedFilters = const {},
  });

  @override
  State<FilterSection> createState() => _FilterSectionState();
}

class _FilterSectionState extends State<FilterSection> {
  late String selectedFilter;
  bool isManualSelection = false; // Track if user manually selected a filter

  @override
  void initState() {
    super.initState();
    selectedFilter = widget.initialFilter;
  }

  @override
  void didUpdateWidget(FilterSection oldWidget) {
    super.didUpdateWidget(oldWidget);

    // If auto-highlighted filters changed and no manual selection, update display
    if (!isManualSelection &&
        widget.autoHighlightedFilters != oldWidget.autoHighlightedFilters) {
      // Don't change selectedFilter, just rebuild to show highlights
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: widget.filters.map((filter) {
            final isSelected = selectedFilter == filter;
            final isAutoHighlighted =
                widget.autoHighlightedFilters.contains(filter) &&
                !isManualSelection;
            final isFirst = filter == widget.filters.first;
            final isLast = filter == widget.filters.last;

            // Determine chip appearance
            final bool shouldHighlight = isSelected || isAutoHighlighted;

            return Padding(
              padding: EdgeInsets.only(
                left: isFirst ? 0 : 4,
                right: isLast ? 0 : 4,
              ),
              child: ChoiceChip(
                label: Text(
                  filter,
                  style: TextStyle(
                    color: shouldHighlight ? Colors.white : Colors.black87,
                    fontWeight: shouldHighlight
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
                selected: shouldHighlight,
                selectedColor: isSelected ? Colors.teal : Colors.teal.shade300,
                backgroundColor: Colors.grey.shade200,
                onSelected: (_) {
                  setState(() {
                    selectedFilter = filter;
                    isManualSelection = true; // User manually clicked
                  });
                  widget.onSelected(filter);
                },
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // Method to reset manual selection (call when search is cleared)
  void resetManualSelection() {
    setState(() {
      isManualSelection = false;
      selectedFilter = 'All';
    });
  }
}
