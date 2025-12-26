// lib/ui/core/widgets/table/activity_table_body.dart

import 'package:flutter/material.dart';
import '../../../../data/models/activity_log_item.dart';
import '../shared/empty_state.dart';
import 'activity_table_row.dart';
import '../../constants/spacing.dart';
import '../../themes/web_colors.dart';

/// Table body with ListView and empty state handling
class ActivityTableBody extends StatefulWidget {
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
  State<ActivityTableBody> createState() => _ActivityTableBodyState();
}

class _ActivityTableBodyState extends State<ActivityTableBody>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _pulseAnimation = CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return _buildSkeletonRows();
    }

    if (widget.items.isEmpty) {
      return const EmptyState();
    }

    return ListView.separated(
      itemCount: widget.items.length,
      separatorBuilder: (context, index) => const Divider(
        height: 1,
        thickness: 1,
        color: WebColors.tableBorder,
      ),
      itemBuilder: (context, index) {
        return ActivityTableRow(
          item: widget.items[index],
          onViewDetails: widget.onViewDetails,
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

  /// Reusable skeleton box with smooth pulsing animation and optional shimmer
  Widget _buildSkeletonBox({
    required double width,
    required double height,
    double borderRadius = 6,
  }) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            // Phase 1 & 2: Better color contrast + looping animation
            color: Color.lerp(
              WebColors.skeletonLoader, // #F5F5F5 (light gray)
              WebColors.tableBorder,    // #CBD5E1 (darker slate)
              _pulseAnimation.value,
            ),
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        );
      },
    );
  }

}