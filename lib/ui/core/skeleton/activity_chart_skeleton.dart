// lib/ui/core/skeleton/activity_chart_skeleton.dart

import 'package:flutter/material.dart';
import 'package:flutter_application_1/ui/core/themes/web_colors.dart';

class ActivityChartSkeleton extends StatelessWidget {
  final Animation<double> pulse;

  const ActivityChartSkeleton({super.key, required this.pulse});

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
          // ── Always visible: title + legend
          Row(
            children: [
              const Text(
                'Activity Overview',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF374151),
                ),
              ),
              const Spacer(),
              Row(
                children: const [
                  Icon(Icons.square, size: 12, color: Color(0xFF10B981)),
                  SizedBox(width: 6),
                  Text(
                    'Number of Activities Per Day',
                    style: TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          // ── Skeleton: chart area
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Y-axis skeleton labels
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(
                    6,
                    (_) => _skeletonBox(width: 16, height: 10),
                  ),
                ),
                const SizedBox(width: 12),
                // Bars
                Expanded(
                  child: Stack(
                    children: [
                      // Grid lines
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(
                          6,
                          (_) => Container(height: 1, color: WebColors.cardBorder),
                        ),
                      ),
                      // Skeleton bars
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [0.4, 0.7, 0.5, 1.0, 0.6, 0.8, 0.45]
                            .map(
                              (ratio) => Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 6),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Expanded(
                                        child: FractionallySizedBox(
                                          alignment: Alignment.bottomCenter,
                                          heightFactor: ratio,
                                          child: AnimatedBuilder(
                                            animation: pulse,
                                            builder: (_, _) => Container(
                                              decoration: BoxDecoration(
                                                color: Color.lerp(
                                                  WebColors.skeletonLoader,
                                                  WebColors.tableBorder,
                                                  pulse.value,
                                                ),
                                                borderRadius: const BorderRadius.vertical(
                                                  top: Radius.circular(4),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      _skeletonBox(width: 24, height: 10),
                                    ],
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}