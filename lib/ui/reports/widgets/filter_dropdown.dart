import 'package:flutter/material.dart';

class FilterDropdown extends StatelessWidget {
  final String selectedFilter;
  final ValueChanged<String> onFilterChanged;
  final Set<String> autoHighlightedFilters;

  const FilterDropdown({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
    required this.autoHighlightedFilters,
  });

  @override
  Widget build(BuildContext context) {
    final filters = ['All', 'Open', 'In Progress', 'Closed'];

    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = selectedFilter == filter;
          final isHighlighted = autoHighlightedFilters.contains(filter);
          final isAll = filter == 'All';

          return Padding(
            padding: EdgeInsets.only(right: index < filters.length - 1 ? 8 : 0),
            child: FilterChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (_) => onFilterChanged(filter),
              backgroundColor: isAll || !isHighlighted
                  ? Colors.grey[100]
                  : Colors.teal[50],
              selectedColor: Colors.teal,
              checkmarkColor: Colors.white,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 13,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              side: BorderSide(
                color: isHighlighted && !isAll
                    ? Colors.teal
                    : Colors.grey.shade300,
                width: isHighlighted && !isAll ? 1.5 : 1,
              ),
            ),
          );
        },
      ),
    );
  }
}