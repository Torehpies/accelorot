// lib/ui/activity_logs/widgets/unified/table_header_with_filters.dart

import 'package:flutter/material.dart';
import '../../models/unified_activity_config.dart';

/// Table header with Category and Type dropdown filters
class TableHeaderWithFilters extends StatelessWidget {
  final String selectedCategory;
  final String selectedType;
  final String? sortColumn;
  final bool sortAscending;
  final ValueChanged<String> onCategoryChanged;
  final ValueChanged<String> onTypeChanged;
  final ValueChanged<String> onSort;

  const TableHeaderWithFilters({
    super.key,
    required this.selectedCategory,
    required this.selectedType,
    required this.sortColumn,
    required this.sortAscending,
    required this.onCategoryChanged,
    required this.onTypeChanged,
    required this.onSort,
  });

  @override
  Widget build(BuildContext context) {
    // Get available types based on selected category
    final availableTypes = UnifiedActivityConfig.getTypesForCategory(selectedCategory);
    
    // Ensure selected type is valid for current category
    final validType = availableTypes.contains(selectedType) ? selectedType : 'All';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        children: [
          // Title Column (sortable)
          Expanded(
            flex: 3,
            child: _buildSortableHeader('Title', 'title'),
          ),
          
          const SizedBox(width: 16),
          
          // Category Dropdown
          Expanded(
            flex: 2,
            child: _buildDropdown(
              label: 'Category',
              value: selectedCategory,
              items: UnifiedActivityConfig.categories,
              onChanged: onCategoryChanged,
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Type Dropdown (dynamic based on category)
          Expanded(
            flex: 2,
            child: _buildDropdown(
              label: 'Type',
              value: validType,
              items: availableTypes,
              onChanged: onTypeChanged,
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Value Column Header
          Expanded(
            flex: 2,
            child: _buildStaticHeader('Value'),
          ),
          
          const SizedBox(width: 16),
          
          // Date Added Column (sortable)
          Expanded(
            flex: 2,
            child: _buildSortableHeader('Date Added', 'date'),
          ),
          
          const SizedBox(width: 16),
          
          // Actions Column Header
          const SizedBox(
            width: 80,
            child: Text(
              'Actions',
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF6B7280),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortableHeader(String label, String column) {
    final isActive = sortColumn == column;
    
    return InkWell(
      onTap: () => onSort(column),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: isActive ? const Color(0xFF374151) : const Color(0xFF6B7280),
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            isActive
                ? (sortAscending ? Icons.arrow_upward : Icons.arrow_downward)
                : Icons.unfold_more,
            size: 16,
            color: isActive ? const Color(0xFF374151) : const Color(0xFF9CA3AF),
          ),
        ],
      ),
    );
  }

  Widget _buildStaticHeader(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontFamily: 'DM Sans',
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: Color(0xFF6B7280),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String> onChanged,
  }) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: value,
        isExpanded: true,
        icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF6B7280)),
        style: const TextStyle(
          fontFamily: 'DM Sans',
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Color(0xFF374151),
        ),
        items: items.map((item) {
          return DropdownMenuItem(
            value: item,
            child: Text(item),
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