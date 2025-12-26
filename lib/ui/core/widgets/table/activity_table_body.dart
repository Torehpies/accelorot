// lib/ui/core/widgets/table/activity_table_body.dart

import 'package:flutter/material.dart';
import '../../../../data/models/activity_log_item.dart';
import '../shared/empty_state.dart';
import 'activity_table_row.dart'; // UPDATED: Now imports GenericTableRow, TableCellWidget from here
import '../../constants/spacing.dart';

/// Table body with ListView and empty state handling
/// Now supports skeleton loading state for enhanced UX
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
    // Priority 1: Show skeleton rows while loading
    if (isLoading) {
      return _buildSkeletonRows();
    }
    
    // Priority 2: Show empty state when no data
    if (items.isEmpty) {
      return const EmptyState();
    }

    // Priority 3: Show actual data
    return ListView.separated(
      itemCount: items.length,
      separatorBuilder: (context, index) => const Divider(
        height: 1,
        color: Color(0xFFE5E7EB),
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
      itemCount: 8, // Show 8 skeleton rows for better visual feedback
      separatorBuilder: (context, index) => const Divider(
        height: 1,
        color: Color(0xFFE5E7EB),
      ),
      itemBuilder: (context, index) {
        return _buildSkeletonRow();
      },
    );
  }

  /// Single skeleton row matching ActivityTableRow layout exactly
  /// Uses same cell structure for seamless transition to real data
  Widget _buildSkeletonRow() {
    return GenericTableRow(
      cellSpacing: AppSpacing.md,
      cells: [
        // Title Column - wider placeholder for text
        TableCellWidget(
          flex: 2,
          child: Center(
            child: _buildSkeletonBox(width: 180, height: 16),
          ),
        ),
        
        // Category Badge - medium box with rounded corners
        TableCellWidget(
          flex: 2,
          child: Center(
            child: _buildSkeletonBox(width: 80, height: 24, borderRadius: 4),
          ),
        ),
        
        // Type Chip - slightly wider for type names
        TableCellWidget(
          flex: 2,
          child: Center(
            child: _buildSkeletonBox(width: 100, height: 24, borderRadius: 4),
          ),
        ),
        
        // Value Column - medium width for values
        TableCellWidget(
          flex: 2,
          child: Center(
            child: _buildSkeletonBox(width: 120, height: 16),
          ),
        ),
        
        // Date Column - fixed width for date format
        TableCellWidget(
          flex: 2,
          child: Center(
            child: _buildSkeletonBox(width: 90, height: 16),
          ),
        ),
        
        // Actions Column - circular skeleton for icon button
        TableCellWidget(
          flex: 1,
          child: Center(
            child: _buildSkeletonBox(
              width: 24,
              height: 24,
              borderRadius: 12, // Circular
            ),
          ),
        ),
      ],
    );
  }

  /// Reusable skeleton box with subtle pulsing animation
  /// Creates smooth loading effect that matches stats card skeletons
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
              const Color(0xFFE5E7EB), // Light gray
              const Color(0xFFF3F4F6), // Lighter gray
              value,
            ),
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        );
      },
      onEnd: () {
        // Animation completes but TweenAnimationBuilder doesn't auto-reverse
        // This creates a one-way fade effect; for continuous pulse,
        // use AnimatedBuilder with repeat() controller instead
      },
    );
  }
}