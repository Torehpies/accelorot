// lib/ui/core/widgets/table/activity_table_body.dart
import 'package:flutter/material.dart';
import '../../../../data/models/activity_log_item.dart';
import '../shared/empty_state.dart';
import 'activity_table_row.dart';
import '../../constants/spacing.dart';
import '../../themes/web_colors.dart';

/// Table body with ListView and empty state handling
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
    if (isLoading) {
      return _buildSkeletonRows();
    }

    if (items.isEmpty) {
      return const EmptyState();
    }

    // Priority 3: Show actual data
    return ListView.separated(
      itemCount: items.length,
      separatorBuilder: (context, index) => const Divider(
        height: 1,
        thickness: 1,
        color: WebColors.tableBorder,
      ),
      itemBuilder: (context, index) {
        return ActivityTableRow(
          item: items[index],
          onViewDetails: onViewDetails,
        );
      },
    );
  }

  /// Build skeleton loading rows with pulsing animation
  Widget _buildSkeletonRows() {
    return ListView.separated(
      itemCount: 8,
      separatorBuilder: (context, index) => const Divider(
        height: 1,
        thickness: 1,
        color: WebColors.tableBorder,
      ),
      itemBuilder: (context, index) {
        return _buildSkeletonRow();
      },
    );
  }

  /// Single skeleton row mimicking the structure of ActivityTableRow
  Widget _buildSkeletonRow() {
    return GenericTableRow(
      cellSpacing: AppSpacing.md,
      cells: [
        // Title Column
        TableCellWidget(
          flex: 2,
          child: Center(
            child: _buildSkeletonBox(width: 180, height: 16),
          ),
        ),
        
        // Category Badge
        TableCellWidget(
          flex: 2,
          child: Center(
            child: _buildSkeletonBox(width: 80, height: 24, borderRadius: 4),
          ),
        ),
        
        // Type Chip
        TableCellWidget(
          flex: 2,
          child: Center(
            child: _buildSkeletonBox(width: 100, height: 24, borderRadius: 4),
          ),
        ),
        
        // Value Column
        TableCellWidget(
          flex: 2,
          child: Center(
            child: _buildSkeletonBox(width: 120, height: 16),
          ),
        ),
        
        // Date Column
        TableCellWidget(
          flex: 2,
          child: Center(
            child: _buildSkeletonBox(width: 90, height: 16),
          ),
        ),
        
        // Actions Column
        TableCellWidget(
          flex: 1,
          child: Center(
            child: _buildSkeletonBox(
              width: 24,
              height: 24,
              borderRadius: 12,
            ),
          ),
        ),
      ],
    );
  }

  /// Reusable skeleton box with subtle pulsing animation
  Widget _buildSkeletonBox({
    required double width,
    required double height,
    double borderRadius = 6,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.3, end: 0.7),
      duration: const Duration(milliseconds: 1500),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: Color.lerp(
              WebColors.tableBorder,
              WebColors.dividerLight,
              value,
            ),
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        );
      },
      onEnd: () {},
    );
  }
}