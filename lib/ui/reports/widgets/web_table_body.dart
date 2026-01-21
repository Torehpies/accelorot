// lib/ui/reports/widgets/web_table_body.dart

import 'package:flutter/material.dart';
import '../../../data/models/report.dart';
import '../../core/widgets/shared/empty_state.dart';
import '../../core/widgets/table/table_row.dart';
import '../../core/themes/web_colors.dart';
import '../../core/constants/spacing.dart';
import 'web_table_row.dart';

class WebTableBody extends StatefulWidget {
  final List<Report> reports;
  final ValueChanged<Report> onView;
  final ValueChanged<Report> onEdit;
  final bool isLoading;

  const WebTableBody({
    super.key,
    required this.reports,
    required this.onView,
    required this.onEdit,
    this.isLoading = false,
  });

  @override
  State<WebTableBody> createState() => _WebTableBodyState();
}

class _WebTableBodyState extends State<WebTableBody>
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

    if (widget.reports.isEmpty) {
      return const EmptyState(
        title: 'No reports found',
        subtitle: 'Try adjusting your filters',
        icon: Icons.report_off,
      );
    }

    return ListView.separated(
      itemCount: widget.reports.length,
      separatorBuilder: (context, index) => const Divider(
        height: 1,
        thickness: 1,
        color: WebColors.tableBorder,
      ),
      itemBuilder: (context, index) {
        return WebTableRow(
          report: widget.reports[index],
          onView: () => widget.onView(widget.reports[index]),
          onEdit: () => widget.onEdit(widget.reports[index]),
        );
      },
    );
  }

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

  Widget _buildSkeletonRow() {
    return GenericTableRow(
      cellSpacing: AppSpacing.md,
      cells: [
        // Title
        TableCellWidget(
          flex: 2,
          child: Center(
            child: _buildSkeletonBox(width: 180, height: 16),
          ),
        ),

        // Category
        TableCellWidget(
          flex: 2,
          child: Center(
            child: _buildSkeletonBox(width: 110, height: 16),
          ),
        ),

        // Status Chip
        TableCellWidget(
          flex: 2,
          child: Center(
            child: _buildSkeletonBox(width: 90, height: 24, borderRadius: 4),
          ),
        ),

        // Priority Badge
        TableCellWidget(
          flex: 2,
          child: Center(
            child: _buildSkeletonBox(width: 70, height: 24, borderRadius: 4),
          ),
        ),

        // Actions - Two icon buttons
        TableCellWidget(
          flex: 1,
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildSkeletonBox(width: 24, height: 24, borderRadius: 12),
                const SizedBox(width: 4),
                _buildSkeletonBox(width: 24, height: 24, borderRadius: 12),
              ],
            ),
          ),
        ),
      ],
    );
  }

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