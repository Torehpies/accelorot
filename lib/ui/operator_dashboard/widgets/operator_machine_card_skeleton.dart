// lib/ui/operator_dashboard/widgets/operator_machine_card_skeleton.dart

import 'package:flutter/material.dart';
import '../../core/skeleton/skeleton_shimmer.dart';

class OperatorMachineCardSkeleton extends StatelessWidget {
  const OperatorMachineCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
      ),
      child: Row(
        children: [
          // Left Icon Bubble skeleton
          SkeletonShimmer(
            width: 44,
            height: 44,
            borderRadius: BorderRadius.circular(22),
          ),
          const SizedBox(width: 16),
          
          // Middle Details skeleton
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: const [
                SkeletonShimmer(width: 140, height: 16),
                SizedBox(height: 6),
                SkeletonShimmer(width: 100, height: 12),
                SizedBox(height: 8),
                SkeletonShimmer(width: 70, height: 16, borderRadius: BorderRadius.all(Radius.circular(8))),
              ],
            ),
          ),

          // Right Days Display skeleton
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: const [
              SkeletonShimmer(width: 32, height: 32),
              SizedBox(height: 4),
              SkeletonShimmer(width: 36, height: 12),
            ],
          ),
          const SizedBox(width: 4),
        ],
      ),
    );
  }
}
