import 'package:flutter/material.dart';
import 'package:flutter_application_1/ui/core/themes/web_colors.dart';
import 'package:flutter_application_1/ui/core/widgets/table/table_row.dart';
import 'package:flutter_application_1/ui/web_landing_page/widgets/download_app.dart';

class SkeletonRow extends StatelessWidget {
  const SkeletonRow({super.key});

  @override
  Widget build(BuildContext context) {
    return GenericTableRow(
      cellSpacing: AppSpacing.md,
      cells: [
        TableCellWidget(
          flex: 2,
          child: Center(child: _SkeletonBox(width: 120, height: 16)),
        ),
        TableCellWidget(
          flex: 2,
          child: Center(child: _SkeletonBox(width: 150, height: 16)),
        ),
        TableCellWidget(
          flex: 1,
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _SkeletonBox(width: 24, height: 24, borderRadius: 12),
                const SizedBox(width: 4),
                _SkeletonBox(width: 24, height: 24, borderRadius: 12),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SkeletonBox extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;

  const _SkeletonBox({
    required this.width,
    required this.height,
    this.borderRadius = 6,
  });

  @override
  State<_SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<_SkeletonBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _anim = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: Color.lerp(
              WebColors.skeletonLoader,
              WebColors.tableBorder,
              _anim.value,
            ),
            borderRadius: BorderRadius.circular(widget.borderRadius),
          ),
        );
      },
    );
  }
}
