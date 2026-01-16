// lib/ui/core/widgets/table/activity_table_row.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../data/models/activity_log_item.dart';
import '../../../activity_logs/models/unified_activity_config.dart';
import '../../../activity_logs/models/activity_enums.dart';
import '../../constants/spacing.dart';
import '../../themes/web_text_styles.dart';
import '../../themes/web_colors.dart';

// TABLE MICRO COMPONENTS

/// Generic table row wrapper with hover effect and optional tap handler
class GenericTableRow extends StatelessWidget {
  final List<Widget> cells;
  final VoidCallback? onTap;
  final EdgeInsets? padding;
  final Color? hoverColor;
  final double? height;
  final double cellSpacing;

  const GenericTableRow({
    super.key,
    required this.cells,
    this.onTap,
    this.padding,
    this.hoverColor,
    this.height,
    this.cellSpacing = 0,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      hoverColor: hoverColor ?? WebColors.hoverBackground,
      child: Container(
        constraints: BoxConstraints(minHeight: height ?? 52),
        padding: padding ??
            const EdgeInsets.symmetric(
              horizontal: AppSpacing.tableCellHorizontal,
              vertical: 8,
            ),
        // Removed the border decoration entirely - separator handles dividers
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
        color: WebColors.badgeBackground,
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

    // Sortable header
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
                  ? WebTextStyles.label.copyWith(color: WebColors.tealAccent)
                  : WebTextStyles.label,
            ),
            const SizedBox(width: 4),
            Icon(
              isActive
                  ? (sortAscending ? Icons.arrow_upward : Icons.arrow_downward)
                  : Icons.unfold_more,
              size: 16,
              color: isActive ? WebColors.tealAccent : WebColors.neutral,
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
    final categoryName =
        UnifiedActivityConfig.getCategoryNameFromActivityType(item.type);

    // Parse the category string to enum, then get color
    final subType = ActivitySubType.fromString(item.category);
    final typeColor = UnifiedActivityConfig.getColorForSubType(subType);

    return GenericTableRow(
      onTap: null,
      hoverColor: WebColors.hoverBackground,
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
              color: WebColors.textLabel,
              onPressed: () => onViewDetails(item),
              tooltip: 'View Details',
            ),
          ),
        ),
      ],
    );
  }
}
