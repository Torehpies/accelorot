// lib/ui/reports/widgets/reports_table_body.dart

import 'package:flutter/material.dart';
import '../../../data/models/report.dart';
import '../../core/widgets/shared/empty_state.dart';
import '../../core/widgets/table/activity_table_row.dart';
import '../../core/themes/web_colors.dart';
import '../../core/constants/spacing.dart';
import 'table_row.dart';

class ReportsTableBody extends StatefulWidget {
  final List<Report> reports;
  final ValueChanged<Report> onViewDetails;
  final bool isLoading;

  const ReportsTableBody({
    super.key,
    required this.reports,
    required this.onViewDetails,
    this.isLoading = false,
  });

  @override
  State<ReportsTableBody> createState() => _ReportsTableBodyState();
}

class _ReportsTableBodyState extends State<ReportsTableBody>
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
        return ReportsTableRow(
          report: widget.reports[index],
          onTap: () => widget.onViewDetails(widget.reports[index]),
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

        // Category Badge
        TableCellWidget(
          flex: 2,
          child: Center(
            child: _buildSkeletonBox(width: 100, height: 24, borderRadius: 4),
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

        // Actions
        TableCellWidget(
          flex: 1,
          child: Center(
            child: _buildSkeletonBox(width: 24, height: 24, borderRadius: 12),
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