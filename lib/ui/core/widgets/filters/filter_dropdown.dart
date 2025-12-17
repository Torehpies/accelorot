// lib/ui/core/widgets/filters/filter_dropdown.dart

import 'package:flutter/material.dart';

/// Reusable styled dropdown for filters
class FilterDropdown extends StatelessWidget {
  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String> onChanged;

  const FilterDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: value,
        isExpanded: true,
        icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF6B7280), size: 20),
        style: const TextStyle(
          fontFamily: 'DM Sans',
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Color(0xFF374151),
        ),
        items: items.map((item) {
          return DropdownMenuItem(
            value: item,
            child: Text('$label: $item'),
          );
        }).toList(),
        onChanged: (newValue) {
          if (newValue != null) {
            onChanged(newValue);
          }
        },
      ),
    );
  }
}