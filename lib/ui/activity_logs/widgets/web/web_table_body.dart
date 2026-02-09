// lib/ui/activity_logs/widgets/web/web_table_body.dart

import 'package:flutter/material.dart';
import '../../../../data/models/activity_log_item.dart';
import '../../../core/widgets/table/table_body.dart';
import '../../../core/widgets/table/table_row.dart';
import '../../../core/constants/spacing.dart';
import '../../../core/themes/web_colors.dart';
import 'web_table_row.dart';

/// Activity-specific wrapper for TableBody
/// Uses ActivityTableRow and provides activity-specific skeleton
class ActivityTableBody extends StatelessWidget {
  final List<ActivityLogItem> items;
  final ValueChanged<ActivityLogItem> onViewDetails;
  final bool isLoading;

  const ActivityTableBody({
    super.key,
    required this.items,
    required this.onViewDetails,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return TableBody<ActivityLogItem>(
      items: items,
      isLoading: isLoading,
      rowBuilder: (item) =>
          ActivityTableRow(item: item, onViewDetails: onViewDetails),
      skeletonRowBuilder: _buildActivitySkeletonRow,
    );
  }

  /// Activity-specific skeleton row matching ActivityTableRow structure
  Widget _buildActivitySkeletonRow() {
    return GenericTableRow(
      cellSpacing: AppSpacing.md,
      cells: [
        // Title Column
        TableCellWidget(
          flex: 2,
          child: Center(child: _SkeletonBox(width: 180, height: 16)),
        ),

        // Category Column
        TableCellWidget(
          flex: 2,
          child: Center(child: _SkeletonBox(width: 90, height: 16)),
        ),

        // Type Chip
        TableCellWidget(
          flex: 2,
          child: Center(
            child: _SkeletonBox(width: 100, height: 24, borderRadius: 4),
          ),
        ),

        // Value Column
        TableCellWidget(
          flex: 2,
          child: Center(child: _SkeletonBox(width: 120, height: 16)),
        ),

        // Date Column
        TableCellWidget(
          flex: 2,
          child: Center(child: _SkeletonBox(width: 90, height: 16)),
        ),

        // Actions Column
        TableCellWidget(
          flex: 1,
          child: Center(
            child: _SkeletonBox(width: 24, height: 24, borderRadius: 12),
          ),
        ),
      ],
    );
  }
}

/// Simple skeleton box for activity table loading state
class _SkeletonBox extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const _SkeletonBox({
    required this.width,
    required this.height,
    this.borderRadius = 6,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: WebColors.skeletonLoader,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}
