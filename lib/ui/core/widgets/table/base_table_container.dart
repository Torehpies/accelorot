// lib/ui/core/widgets/table/base_table_container.dart

import 'package:flutter/material.dart';
import '../../constants/spacing.dart';
import '../../themes/web_colors.dart';

/// Reusable base table container with consistent styling
/// Provides: filter header, bordered table wrapper, pagination footer
class BaseTableContainer extends StatelessWidget {
  /// Left section of filter bar (title, filters, etc.)
  final Widget? leftHeaderWidget;

  /// Right section of filter bar (search, date filter, etc.)
  final List<Widget>? rightHeaderWidgets;

  /// Table header (column titles, filters in headers)
  final Widget tableHeader;

  /// Table body (scrollable content)
  final Widget tableBody;

  /// Optional pagination controls at bottom
  final Widget? paginationWidget;

  /// Custom container padding (default: symmetric horizontal:16, vertical:0)
  final EdgeInsets? tablePadding;

  /// Custom border color
  final Color? borderColor;

  const BaseTableContainer({
    super.key,
    this.leftHeaderWidget,
    this.rightHeaderWidgets,
    required this.tableHeader,
    required this.tableBody,
    this.paginationWidget,
    this.tablePadding,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: WebColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: WebColors.cardBorder),
      ),
      child: Column(
        children: [
          // Filter Header Bar (if provided)
          if (leftHeaderWidget != null || rightHeaderWidgets != null)
            _buildFilterBar(),

          // Table Wrapper (Header + Body with border)
          Expanded(
            child: Padding(
              padding:
                  tablePadding ??
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: borderColor ?? WebColors.tableBorder,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    // Table Header with bottom border
                    Container(
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: WebColors.tableBorder,
                            width: 1,
                          ),
                        ),
                      ),
                      child: tableHeader,
                    ),

                    // Table Body
                    Expanded(child: tableBody),
                  ],
                ),
              ),
            ),
          ),

          // Pagination Footer (if provided)
          if (paginationWidget != null)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.tableCellHorizontal,
                vertical: AppSpacing.lg,
              ),
              child: paginationWidget!,
            ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Left section - natural sizing, no Expanded wrapper
          if (leftHeaderWidget != null) leftHeaderWidget!,

          // Spacer eats all remaining space, pushes right section to edge
          if (leftHeaderWidget != null && rightHeaderWidgets != null)
            const Spacer(),

          // Right section - compact and right-aligned
          if (rightHeaderWidgets != null)
            ...rightHeaderWidgets!.map((widget) {
              final index = rightHeaderWidgets!.indexOf(widget);
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [if (index > 0) const SizedBox(width: 12), widget],
              );
            }),
        ],
      ),
    );
  }
}
