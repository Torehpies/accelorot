// lib/ui/activity_logs/widgets/unified/activity_data_table.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../data/models/activity_log_item.dart';
import '../../models/unified_activity_config.dart';
import 'table_header_with_filters.dart';

/// Main data table for unified activity view
class ActivityDataTable extends StatelessWidget {
  final List<ActivityLogItem> items;
  final String selectedCategory;
  final String selectedType;
  final String? sortColumn;
  final bool sortAscending;
  final ValueChanged<String> onCategoryChanged;
  final ValueChanged<String> onTypeChanged;
  final ValueChanged<String> onSort;
  final ValueChanged<ActivityLogItem> onViewDetails;

  const ActivityDataTable({
    super.key,
    required this.items,
    required this.selectedCategory,
    required this.selectedType,
    required this.sortColumn,
    required this.sortAscending,
    required this.onCategoryChanged,
    required this.onTypeChanged,
    required this.onSort,
    required this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          // Table Header with Filters
          TableHeaderWithFilters(
            selectedCategory: selectedCategory,
            selectedType: selectedType,
            sortColumn: sortColumn,
            sortAscending: sortAscending,
            onCategoryChanged: onCategoryChanged,
            onTypeChanged: onTypeChanged,
            onSort: onSort,
          ),
          
          // Table Body
          Expanded(
            child: items.isEmpty
                ? _buildEmptyState()
                : ListView.separated(
                    itemCount: items.length,
                    separatorBuilder: (context, index) => const Divider(
                      height: 1,
                      color: Color(0xFFE5E7EB),
                    ),
                    itemBuilder: (context, index) {
                      return _buildTableRow(context, items[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 56,
              color: Color(0xFFD1D5DB),
            ),
            SizedBox(height: 12),
            Text(
              'No activities found',
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6B7280),
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Try adjusting your filters',
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 13,
                color: Color(0xFF9CA3AF),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableRow(BuildContext context, ActivityLogItem item) {
    final categoryName = UnifiedActivityConfig.getCategoryNameFromActivityType(item.type);

    return InkWell(
      onTap: () => onViewDetails(item),
      hoverColor: const Color(0xFFF9FAFB),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            // Title Column
            Expanded(
              flex: 3,
              child: Text(
                item.title,
                style: const TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF111827),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            
            const SizedBox(width: 12),
            
            // Category Badge (gray)
            Expanded(
              flex: 2,
              child: _buildCategoryBadge(categoryName),
            ),
            
            const SizedBox(width: 12),
            
            // Type Chip (colored)
            Expanded(
              flex: 2,
              child: _buildTypeChip(item.category),
            ),
            
            const SizedBox(width: 12),
            
            // Value Column
            Expanded(
              flex: 2,
              child: Text(
                item.value,
                style: const TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF111827),
                ),
              ),
            ),
            
            const SizedBox(width: 12),
            
            // Date Added Column
            Expanded(
              flex: 2,
              child: Text(
                DateFormat('MM/dd/yyyy').format(item.timestamp),
                style: const TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF111827),
                ),
              ),
            ),
            
            const SizedBox(width: 12),
            
            // Actions Column
            SizedBox(
              width: 60,
              child: IconButton(
                icon: const Icon(Icons.visibility_outlined, size: 18),
                color: const Color(0xFF6B7280),
                onPressed: () => onViewDetails(item),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryBadge(String category) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        category,
        style: const TextStyle(
          fontFamily: 'DM Sans',
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: Color(0xFF6B7280),
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildTypeChip(String type) {
    final color = UnifiedActivityConfig.getColorForType(type);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        type,
        style: TextStyle(
          fontFamily: 'DM Sans',
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: color,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}