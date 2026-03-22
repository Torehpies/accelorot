// lib/ui/core/skeleton/report_donut_chart_skeleton.dart

import 'package:flutter/material.dart';
import 'package:flutter_application_1/ui/core/themes/web_colors.dart';

class ReportDonutChartSkeleton extends StatelessWidget {
  final Animation<double> pulse;

  const ReportDonutChartSkeleton({super.key, required this.pulse});

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
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Always visible: title
          const Text(
            'Report Status',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 16),

          // ── Skeleton: donut circle
          Expanded(
            child: Center(
              child: AspectRatio(
                aspectRatio: 1,
                child: _skeletonBox(
                  width: double.infinity,
                  height: double.infinity,
                  borderRadius: 999,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // ── Always visible: "Legend:" label
          const Text(
            'Legend:',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 8),

          // ── Skeleton: legend rows
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [72.0, 56.0, 80.0, 64.0].map((width) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _skeletonBox(width: 14, height: 14, borderRadius: 2),
                  const SizedBox(width: 6),
                  _skeletonBox(width: width, height: 11),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}