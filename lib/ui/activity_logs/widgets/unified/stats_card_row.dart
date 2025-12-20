// lib/ui/activity_logs/widgets/unified/stats_card_row.dart

import 'package:flutter/material.dart';
import '../../../core/widgets/base_stats_card.dart';

/// Stats card row with month-over-month change tracking
class StatsCardRow extends StatelessWidget {
  final Map<String, Map<String, dynamic>> countsWithChange;
  final bool isLoading;

  const StatsCardRow({
    super.key,
    required this.countsWithChange,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Substrates Card
        Expanded(
          child: BaseStatsCard(
            title: 'Substrates',
            value: countsWithChange['substrates']?['count'] ?? 0,
            icon: Icons.eco,
            iconColor: const Color(0xFF10B981),
            backgroundColor: const Color(0xFFD1FAE5),
            changeText: countsWithChange['substrates']?['change'],
            subtext: 'added substrate this month',
            isPositive: countsWithChange['substrates']?['isPositive'],
            isLoading: isLoading,
          ),
        ),
        const SizedBox(width: 16),

        // Alerts Card
        Expanded(
          child: BaseStatsCard(
            title: 'Alerts',
            value: countsWithChange['alerts']?['count'] ?? 0,
            icon: Icons.warning_amber_rounded,
            iconColor: const Color(0xFFF59E0B),
            backgroundColor: const Color(0xFFFEF3C7),
            changeText: countsWithChange['alerts']?['change'],
            subtext: 'added alerts this month',
            isPositive: countsWithChange['alerts']?['isPositive'],
            isLoading: isLoading,
          ),
        ),
        const SizedBox(width: 16),

        // Operations & AI Card
        Expanded(
          child: BaseStatsCard(
            title: 'Operations & AI',
            value: countsWithChange['operations']?['count'] ?? 0,
            icon: Icons.lightbulb_outline,
            iconColor: const Color(0xFF3B82F6),
            backgroundColor: const Color(0xFFDBEAFE),
            changeText: countsWithChange['operations']?['change'],
            subtext: 'operators retired this month',
            isPositive: countsWithChange['operations']?['isPositive'],
            isLoading: isLoading,
          ),
        ),
        const SizedBox(width: 16),

        // Reports Card
        Expanded(
          child: BaseStatsCard(
            title: 'Reports',
            value: countsWithChange['reports']?['count'] ?? 0,
            icon: Icons.description_outlined,
            iconColor: const Color(0xFF8B5CF6),
            backgroundColor: const Color(0xFFEDE9FE),
            changeText: countsWithChange['reports']?['change'],
            subtext: 'new reports this month',
            isPositive: countsWithChange['reports']?['isPositive'],
            isLoading: isLoading,
          ),
        ),
      ],
    );
  }
}
