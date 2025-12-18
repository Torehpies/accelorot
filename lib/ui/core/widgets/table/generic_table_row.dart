// lib/ui/core/widgets/table/generic_table_row.dart

import 'package:flutter/material.dart';
import '../../constants/spacing.dart';

/// A reusable table row that accepts a list of children (cells)
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
