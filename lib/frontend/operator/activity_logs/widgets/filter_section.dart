import 'package:flutter/material.dart';

class FilterSection extends StatefulWidget {
  final List<String> filters;
  final ValueChanged<String> onSelected;

  const FilterSection({
    super.key,
    required this.filters,
    required this.onSelected,
  });

  @override
  State<FilterSection> createState() => _FilterSectionState();
}

class _FilterSectionState extends State<FilterSection> {
  String selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: widget.filters.map((filter) {
          final isSelected = selectedFilter == filter;
          return ChoiceChip(
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
          );
        }).toList(),
      ),
    );
  }
}
