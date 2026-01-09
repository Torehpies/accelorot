// lib/ui/machine_management/new_widgets/machine_table_body.dart

import 'package:flutter/material.dart';
import '../../../data/models/machine_model.dart';
import '../../core/widgets/shared/empty_state.dart';
import '../../core/widgets/table/activity_table_row.dart';
import '../../core/themes/web_colors.dart';
import '../../core/constants/spacing.dart';
import 'machine_table_row.dart';

class MachineTableBody extends StatefulWidget {
  final List<MachineModel> machines;
  final Function(MachineModel) onEdit;
  final bool isLoading;

  const MachineTableBody({
    super.key,
    required this.machines,
    required this.onEdit,
    this.isLoading = false,
  });

  @override
  State<MachineTableBody> createState() => _MachineTableBodyState();
}

class _MachineTableBodyState extends State<MachineTableBody>
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

    if (widget.machines.isEmpty) {
      return const EmptyState(
        title: 'No machines found',
        subtitle: 'Try adjusting your filters or add a new machine',
        icon: Icons.precision_manufacturing_outlined,
      );
    }

    return ListView.separated(
      itemCount: widget.machines.length,
      separatorBuilder: (context, index) => const Divider(
        height: 1,
        thickness: 1,
        color: WebColors.tableBorder,
      ),
      itemBuilder: (context, index) {
        final machine = widget.machines[index];
        return MachineTableRow(
          machine: machine,
          onEdit: () => widget.onEdit(machine),
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
        // Machine ID
        TableCellWidget(
          flex: 2,
          child: Center(
            child: _buildSkeletonBox(width: 100, height: 16),
          ),
        ),

        // Machine Name
        TableCellWidget(
          flex: 2,
          child: Center(
            child: _buildSkeletonBox(width: 140, height: 16),
          ),
        ),

        // Date Added
        TableCellWidget(
          flex: 2,
          child: Center(
            child: _buildSkeletonBox(width: 100, height: 16),
          ),
        ),

        // Status Chip
        TableCellWidget(
          flex: 2,
          child: Center(
            child: _buildSkeletonBox(width: 80, height: 24, borderRadius: 4),
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