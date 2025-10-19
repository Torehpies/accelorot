//filter_section.dart
import 'package:flutter/material.dart';

class FilterSection extends StatefulWidget {
  final List<String> filters;
  final ValueChanged<String> onSelected;
  final String initialFilter;

  const FilterSection({
    super.key,
    required this.filters,
    required this.onSelected,
    this.initialFilter = 'All',
  });

  @override
  State<FilterSection> createState() => _FilterSectionState();
}

class _FilterSectionState extends State<FilterSection> {
  late String selectedFilter;

  @override
  void initState() {
    super.initState();
    selectedFilter = widget.initialFilter;
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
            final isFirst = filter == widget.filters.first;
            final isLast = filter == widget.filters.last;
            
            return Padding(
              padding: EdgeInsets.only(
                left: isFirst ? 0 : 4,
                right: isLast ? 0 : 4,
              ),
              child: ChoiceChip(
                label: Text(
                  filter,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                selected: isSelected,
                selectedColor: Colors.teal,
                backgroundColor: Colors.grey.shade200,
                onSelected: (_) {
                  setState(() => selectedFilter = filter);
                  widget.onSelected(filter);
                },
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}