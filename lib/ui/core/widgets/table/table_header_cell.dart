// lib/ui/core/widgets/table/table_header_cell.dart

import 'package:flutter/material.dart';
import '../../themes/web_text_styles.dart';

/// Reusable table header cell with optional sorting
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
              style: isActive ? WebTextStyles.label.copyWith(color: const Color(0xFF374151)) : WebTextStyles.label,
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