// lib/ui/machine_management/widgets/admin/table/machine_table_header_cell.dart

import 'package:flutter/material.dart';
import '../../core/themes/web_colors.dart';
import '../../core/themes/web_text_styles.dart';

class MachineTableHeaderCell extends StatelessWidget {
  final String label;
  final bool sortable;
  final String sortColumn;
  final String currentSortColumn;
  final bool sortAscending;
  final VoidCallback? onSort;

  const MachineTableHeaderCell({
    super.key,
    required this.label,
    this.sortable = false,
    required this.sortColumn,
    required this.currentSortColumn,
    this.sortAscending = true,
    this.onSort,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = sortable && sortColumn == currentSortColumn;

    if (!sortable) {
      return Center(child: Text(label, style: WebTextStyles.label));
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
                  ? WebTextStyles.label.copyWith(color: WebColors.success)
                  : WebTextStyles.label,
            ),
            const SizedBox(width: 4),
            Icon(
              isActive
                  ? (sortAscending ? Icons.arrow_upward : Icons.arrow_downward)
                  : Icons.unfold_more,
              size: 16,
              color: isActive ? WebColors.success : WebColors.neutral,
            ),
          ],
        ),
      ),
    );
  }
}
