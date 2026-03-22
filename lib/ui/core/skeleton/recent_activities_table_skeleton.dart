// lib/ui/core/skeleton/recent_activities_table_skeleton.dart

import 'package:flutter/material.dart';
import 'package:flutter_application_1/ui/core/themes/web_colors.dart';

class RecentActivitiesTableSkeleton extends StatelessWidget {
  final Animation<double> pulse;
  final bool isCondensed;

  const RecentActivitiesTableSkeleton({
    super.key,
    required this.pulse,
    this.isCondensed = false,
  });

  Widget _skeletonBox({
    required double width,
    required double height,
    double borderRadius = 6,
  }) {
    return AnimatedBuilder(
      animation: pulse,
      builder: (_, _) => Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Color.lerp(
            WebColors.skeletonLoader,
            WebColors.tableBorder,
            pulse.value,
          ),
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: 8,
      padding: EdgeInsets.zero,
      separatorBuilder: (_, _) =>
          const Divider(height: 1, color: Color(0xFFE5E7EB)),
      itemBuilder: (_, _) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ── Icon placeholder
            _skeletonBox(width: 36, height: 36, borderRadius: 8),
            const SizedBox(width: 12),

            // ── Title + subtitle
            Expanded(
              flex: isCondensed ? 4 : 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _skeletonBox(width: 140, height: 12),
                  const SizedBox(height: 6),
                  _skeletonBox(width: 80, height: 10),
                ],
              ),
            ),

            if (!isCondensed) ...[
              // ── Machine / Batch
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _skeletonBox(width: 80, height: 12),
                    const SizedBox(height: 6),
                    _skeletonBox(width: 56, height: 10),
                  ],
                ),
              ),
              // ── Status
              Expanded(
                flex: 2,
                child: _skeletonBox(width: 60, height: 12),
              ),
            ],

            // ── Date
            Expanded(
              flex: 1,
              child: Align(
                alignment: Alignment.centerRight,
                child: _skeletonBox(width: 40, height: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}