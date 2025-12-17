// lib/ui/core/widgets/table/table_header_cell.dart

import 'package:flutter/material.dart';

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
      return Text(
        label,
        style: const TextStyle(
          fontFamily: 'DM Sans',
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Color(0xFF6B7280),
        ),
      );
    }

    return InkWell(
      onTap: onSort,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 13,
              fontWeight: FontWeight.w600,
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
}