// lib/ui/core/widgets/table/activity_table_row.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../data/models/activity_log_item.dart';
import '../../../activity_logs/models/unified_activity_config.dart';
import '../../constants/spacing.dart';
import '../../themes/web_text_styles.dart';

// ============================================================================
// TABLE MICRO COMPONENTS

/// Generic table row wrapper with hover effect and optional tap handler
/// Provides consistent row styling and interaction across all table views
class GenericTableRow extends StatelessWidget {
  final List<Widget> cells;
  final VoidCallback? onTap;
  final EdgeInsets? padding;
  final Color? hoverColor;
  final double? height;
  final bool showDivider;
  final double cellSpacing;

  const GenericTableRow({
    super.key,
    required this.cells,
    this.onTap,
    this.padding,
    this.hoverColor,
    this.height,
    this.showDivider = true,
    this.cellSpacing = 0,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      hoverColor: hoverColor ?? const Color(0xFFF9FAFB),
      child: Container(
        constraints: BoxConstraints(minHeight: height ?? 52),
        padding: padding ?? const EdgeInsets.symmetric(
          horizontal: AppSpacing.tableCellHorizontal,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          border: showDivider 
            ? const Border(bottom: BorderSide(color: Color(0xFFE5E7EB), width: 1))
            : null,
        ),
        child: Row(
          children: _buildCellsWithSpacing(),
        ),
      ),
    );
  }

  List<Widget> _buildCellsWithSpacing() {
    if (cellSpacing == 0) return cells;
    
    final List<Widget> spacedCells = [];
    for (int i = 0; i < cells.length; i++) {
      spacedCells.add(cells[i]);
      if (i < cells.length - 1) {
        spacedCells.add(SizedBox(width: cellSpacing));
      }
    }
    return spacedCells;
  }
}

/// Table cell widget with flex-based sizing
/// Wraps content in Expanded widget for proper column distribution
class TableCellWidget extends StatelessWidget {
  final int flex;
  final Widget child;

  const TableCellWidget({
    super.key,
    required this.flex,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: child,
    );
  }
}

/// Gray badge component for category display in tables
/// Used for categorical information with neutral styling
class TableBadge extends StatelessWidget {
  final String text;

  const TableBadge({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: WebTextStyles.bodyMediumGray.copyWith(fontSize: 12),
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

/// Colored chip component for type/status display in tables
/// Uses custom colors to represent different types or states
class TableChip extends StatelessWidget {
  final String text;
  final Color color;

  const TableChip({
    super.key,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        text,
        style: WebTextStyles.label.copyWith(fontSize: 12, color: color),
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

/// Table header cell with optional sorting functionality
/// Displays column labels and handles sort state visualization
class TableHeaderCell extends StatelessWidget {
  final String label;
  final bool sortable;
  final String? sortColumn;
  final String? currentSortColumn;
  final bool sortAscending;
  final VoidCallback? onSort;

  const TableHeaderCell({
    super.key,
    required this.label,
    this.sortable = false,
    this.sortColumn,
    this.currentSortColumn,
    this.sortAscending = true,
    this.onSort,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = sortable && sortColumn == currentSortColumn;

    if (!sortable) {
      return Center(
        child: Text(
          label,
          style: WebTextStyles.label,
        ),
      );
    }

    return Center(
      child: InkWell(
        onTap: onSort,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: isActive 
                ? WebTextStyles.label.copyWith(color: const Color(0xFF374151)) 
                : WebTextStyles.label,
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
      ),
    );
  }
}

// ============================================================================
// MAIN ACTIVITY TABLE ROW COMPONENT
// ============================================================================

/// Single table row component for activity log items
/// Displays: Title, Category Badge, Type Chip, Value, Date, and Actions
class ActivityTableRow extends StatelessWidget {
  final ActivityLogItem item;
  final ValueChanged<ActivityLogItem> onViewDetails;

  const ActivityTableRow({
    super.key,
    required this.item,
    required this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    final categoryName = UnifiedActivityConfig.getCategoryNameFromActivityType(item.type);
    final typeColor = UnifiedActivityConfig.getColorForType(item.category);

    return GenericTableRow(
      onTap: () => onViewDetails(item),
      cellSpacing: AppSpacing.md,
      cells: [
        // Title Column
        TableCellWidget(
          flex: 2,
          child: Text(
            item.title,
            style: WebTextStyles.body,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ),
        
        // Category Badge
        TableCellWidget(
          flex: 2,
          child: Center(
            child: TableBadge(text: categoryName),
          ),
        ),
        
        // Type Chip
        TableCellWidget(
          flex: 2,
          child: Center(
            child: TableChip(text: item.category, color: typeColor),
          ),
        ),
        
        // Value Column
        TableCellWidget(
          flex: 2,
          child: Text(
            item.value,
            style: WebTextStyles.body,
            textAlign: TextAlign.center,
          ),
        ),
        
        // Date Added Column
        TableCellWidget(
          flex: 2,
          child: Text(
            DateFormat('MM/dd/yyyy').format(item.timestamp),
            style: WebTextStyles.body,
            textAlign: TextAlign.center,
          ),
        ),
        
        // Actions Column
        TableCellWidget(
          flex: 1,
          child: Center(
            child: IconButton(
              icon: const Icon(Icons.open_in_new, size: 18),
              color: const Color(0xFF6B7280),
              onPressed: () => onViewDetails(item),
              tooltip: 'View Details',
            ),
          ),
        ),
      ],
    );
  }
}