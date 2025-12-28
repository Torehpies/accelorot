// lib/ui/reports/widgets/reports_stats_row.dart

import 'package:flutter/material.dart';
import '../../core/widgets/base_stats_card.dart';
import '../../core/themes/web_colors.dart';

class ReportsStatsRow extends StatelessWidget {
  final Map<String, Map<String, dynamic>> statsWithChange;
  final bool isLoading;

  const ReportsStatsRow({
    super.key,
    required this.statsWithChange,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Completed Reports Card
        Expanded(
          child: BaseStatsCard(
            title: 'Completed Reports',
            value: statsWithChange['completed']?['count'] ?? 0,
            icon: Icons.check_circle_outline,
            iconColor: WebColors.success,
            backgroundColor: const Color(0xFFD1FAE5), // green-100
            changeText: statsWithChange['completed']?['change'],
            subtext: 'completed reports this month',
            isPositive: statsWithChange['completed']?['isPositive'],
            isLoading: isLoading,
          ),
        ),
        const SizedBox(width: 16),
        
        // Open Reports Card
        Expanded(
          child: BaseStatsCard(
            title: 'Open Reports',
            value: statsWithChange['open']?['count'] ?? 0,
            icon: Icons.folder_open,
            iconColor: WebColors.info,
            backgroundColor: const Color(0xFFDBEAFE), // blue-100
            changeText: statsWithChange['open']?['change'],
            subtext: 'opened reports this month',
            isPositive: statsWithChange['open']?['isPositive'],
            isLoading: isLoading,
          ),
        ),
        const SizedBox(width: 16),
        
        // In Progress Reports Card
        Expanded(
          child: BaseStatsCard(
            title: 'In Progress Reports',
            value: statsWithChange['inProgress']?['count'] ?? 0,
            icon: Icons.pending_actions,
            iconColor: WebColors.warning,
            backgroundColor: const Color(0xFFFEF3C7), // amber-100
            changeText: statsWithChange['inProgress']?['change'],
            subtext: 'reports started this month',
            isPositive: statsWithChange['inProgress']?['isPositive'],
            isLoading: isLoading,
          ),
        ),
        const SizedBox(width: 16),
        
        // On Hold Reports Card
        Expanded(
          child: BaseStatsCard(
            title: 'On Hold Reports',
            value: statsWithChange['onHold']?['count'] ?? 0,
            icon: Icons.pause_circle_outline,
            iconColor: WebColors.error,
            backgroundColor: const Color(0xFFFEE2E2), // red-100 
            changeText: statsWithChange['onHold']?['change'],
            subtext: 'closed reports this month',
            isPositive: statsWithChange['onHold']?['isPositive'],
            isLoading: isLoading,
          ),
        ),
      ],
    );
  }
}