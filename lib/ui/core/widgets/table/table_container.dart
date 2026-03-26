// lib/ui/core/widgets/table/table_container.dart

import 'package:flutter/material.dart';
import '../../constants/spacing.dart';
import '../../themes/web_colors.dart';

/// Reusable base table container with consistent styling.
/// Provides: filter header, bordered table wrapper, pagination footer.
class BaseTableContainer extends StatelessWidget {
  /// Left section of filter bar (tabs, title, etc.)
  final Widget? leftHeaderWidget;

  /// Right section of filter bar (search, filters, add button, etc.)
  final List<Widget>? rightHeaderWidgets;

  /// Column header row — nullable, skipped entirely when null
  final Widget? tableHeader;

  /// Scrollable table content
  final Widget tableBody;

  /// Optional pagination footer
  final Widget? paginationWidget;

  final EdgeInsets? tablePadding;
  final Color? borderColor;

  const BaseTableContainer({
    super.key,
    this.leftHeaderWidget,
    this.rightHeaderWidgets,
    this.tableHeader,
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
          // ── Filter header bar ──
          if (leftHeaderWidget != null || rightHeaderWidgets != null)
            _buildFilterBar(),

          // ── Bordered table wrapper ──
          Expanded(
            child: Padding(
              padding: tablePadding ??
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
                    // ── Table header — skipped when null ──
                    if (tableHeader != null)
                      Container(
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: WebColors.tableBorder,
                              width: 1,
                            ),
                          ),
                        ),
                        child: tableHeader!,
                      ),

                    // ── Table body ──
                    Expanded(child: tableBody),
                  ],
                ),
              ),
            ),
          ),

          // ── Pagination footer ──
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
          ?leftHeaderWidget,
          if (leftHeaderWidget != null && rightHeaderWidgets != null)
            const Spacer(),
          if (rightHeaderWidgets != null)
            ...rightHeaderWidgets!.map((widget) {
              final index = rightHeaderWidgets!.indexOf(widget);
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (index > 0) const SizedBox(width: 12),
                  widget,
                ],
              );
            }),
        ],
      ),
    );
  }
}
