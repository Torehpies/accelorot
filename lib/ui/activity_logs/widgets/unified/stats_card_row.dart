// lib/ui/activity_logs/widgets/unified/stats_card_row.dart

import 'package:flutter/material.dart';
import '../../../core/widgets/base_stats_card.dart';
import '../../../core/constants/spacing.dart';

/// Stats card row at the top of unified activity view
/// Now uses BaseStatsCard for consistency
class StatsCardRow extends StatelessWidget {
  final Map<String, int> counts;

  const StatsCardRow({
    super.key,
    required this.counts,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: BaseStatsCard(
            title: 'Substrates',
            value: counts['substrates'] ?? 0,
            icon: Icons.eco,
            iconColor: const Color(0xFF10B981),
            backgroundColor: const Color(0xFFD1FAE5),
            showIconBackground: false,
          ),
        ),
        const SizedBox(width: AppSpacing.cardGap),
        Expanded(
          child: BaseStatsCard(
            title: 'Alerts',
            value: counts['alerts'] ?? 0,
            icon: Icons.warning,
            iconColor: const Color(0xFFF59E0B),
            backgroundColor: const Color(0xFFFEF3C7),
            showIconBackground: false,
          ),
        ),
        const SizedBox(width: AppSpacing.cardGap),
        Expanded(
          child: BaseStatsCard(
            title: 'Operations & AI',
            value: counts['operations'] ?? 0,
            icon: Icons.lightbulb,
            iconColor: const Color(0xFF3B82F6),
            backgroundColor: const Color(0xFFDBEAFE),
            showIconBackground: false,
          ),
        ),
        const SizedBox(width: AppSpacing.cardGap),
        Expanded(
          child: BaseStatsCard(
            title: 'Reports',
            value: counts['reports'] ?? 0,
            icon: Icons.description,
            iconColor: const Color(0xFF8B5CF6),
            backgroundColor: const Color(0xFFEDE9FE),
            showIconBackground: false,
          ),
        ),
      ],
    );
  }
}