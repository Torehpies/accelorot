// lib/ui/core/widgets/table/table_body.dart

import 'package:flutter/material.dart';
import '../shared/empty_state.dart';
import '../../constants/spacing.dart';
import '../../themes/web_colors.dart';

/// Generic table body with ListView and empty state handling
/// T: The type of items in the list
class TableBody<T> extends StatefulWidget {
  final List<T> items;
  final Widget Function(T item) rowBuilder;
  final Widget Function()? skeletonRowBuilder;
  final bool isLoading;
  final Widget? emptyStateWidget;

  const TableBody({
    super.key,
    required this.items,
    required this.rowBuilder,
    this.skeletonRowBuilder,
    this.isLoading = false,
    this.emptyStateWidget,
  });

  @override
  State<TableBody<T>> createState() => _TableBodyState<T>();
}

class _TableBodyState<T> extends State<TableBody<T>>
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
      return widget.emptyStateWidget ?? const EmptyState();
    }

    return ListView.separated(
      itemCount: widget.items.length,
      separatorBuilder: (context, index) =>
          const Divider(height: 1, thickness: 1, color: WebColors.tableBorder),
      itemBuilder: (context, index) {
        return widget.rowBuilder(widget.items[index]);
      },
    );
  }

  /// Build skeleton loading rows with pulsing animation
  Widget _buildSkeletonRows() {
    return ListView.separated(
      itemCount: 8,
      separatorBuilder: (context, index) =>
          const Divider(height: 1, thickness: 1, color: WebColors.tableBorder),
      itemBuilder: (context, index) {
        return widget.skeletonRowBuilder?.call() ?? _buildDefaultSkeletonRow();
      },
    );
  }

  /// Default skeleton row (can be overridden via skeletonRowBuilder)
  Widget _buildDefaultSkeletonRow() {
    return Container(
      constraints: const BoxConstraints(minHeight: 52),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.tableCellHorizontal,
        vertical: 8,
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildSkeletonBox(width: double.infinity, height: 16),
          ),
        ],
      ),
    );
  }

  /// Reusable skeleton box with smooth pulsing animation
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
            color: Color.lerp(
              WebColors.skeletonLoader,
              WebColors.tableBorder,
              _pulseAnimation.value,
            ),
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        );
      },
    );
  }
}
