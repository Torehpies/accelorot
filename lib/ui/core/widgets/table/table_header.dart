// lib/ui/core/widgets/table/table_header.dart

import 'package:flutter/material.dart';
import '../../constants/spacing.dart';
import '../../themes/web_colors.dart';

/// Generic table header that accepts custom column widgets
/// Provides consistent styling and layout for any table header
class TableHeader extends StatelessWidget {
  final List<Widget> columns;
  final bool isLoading;
  final EdgeInsets? padding;
  final Color? backgroundColor;

  const TableHeader({
    super.key,
    required this.columns,
    this.isLoading = false,
    this.padding,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isLoading ? 0.7 : 1.0,
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor ?? WebColors.pageBackground,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(8),
            topRight: Radius.circular(8),
          ),
        ),
        padding: padding ??
            const EdgeInsets.symmetric(
              horizontal: AppSpacing.tableCellHorizontal,
              vertical: 8,
            ),
        child: Row(
          children: _buildColumnsWithSpacing(),
        ),
      ),
    );
  }

  /// Build columns with consistent spacing
  List<Widget> _buildColumnsWithSpacing() {
    if (columns.isEmpty) return [];

    final List<Widget> spacedColumns = [];
    for (int i = 0; i < columns.length; i++) {
      spacedColumns.add(columns[i]);
      if (i < columns.length - 1) {
        spacedColumns.add(const SizedBox(width: AppSpacing.md));
      }
    }
    return spacedColumns;
  }
}