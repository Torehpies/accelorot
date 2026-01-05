import 'package:flutter/material.dart';
import 'sortable_column_header.dart';
import 'status_filter_header.dart';

class MachineTableHeader extends StatelessWidget {
  final String sortColumn;
  final bool ascending;
  final String statusFilter;
  final List<String> statusOptions;
  final Function(String) onSort;
  final Function(String) onFilterChanged;

  const MachineTableHeader({
    super.key,
    required this.sortColumn,
    required this.ascending,
    required this.statusFilter,
    required this.statusOptions,
    required this.onSort,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: const BoxDecoration(
        color: Color(0xFFF9FAFB),
        borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: SortableColumnHeader(
              text: 'Machine ID',
              isCurrentSort: sortColumn == 'ID',
              ascending: ascending,
              onTap: () => onSort('ID'),
            ),
          ),
          Expanded(
            flex: 3,
            child: SortableColumnHeader(
              text: 'Name',
              isCurrentSort: sortColumn == 'Name',
              ascending: ascending,
              onTap: () => onSort('Name'),
            ),
          ),
          Expanded(
            flex: 2,
            child: SortableColumnHeader(
              text: 'Created',
              isCurrentSort: sortColumn == 'Created',
              ascending: ascending,
              onTap: () => onSort('Created'),
            ),
          ),
          Expanded(
            flex: 2,
            child: StatusFilterHeader(
              currentFilter: statusFilter,
              options: statusOptions,
              onFilterChanged: onFilterChanged,
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: Text(
                'Actions',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF6B7280),
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}