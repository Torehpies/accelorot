// lib/ui/activity_logs/widgets/web/stats_card_row.dart

import 'package:flutter/material.dart';
import '../../../core/widgets/sample_cards/base_stats_card.dart';
import '../../../core/themes/web_colors.dart';
import '../../models/activity_common.dart';

/// Stats card row with progressive loading support
class StatsCardRow extends StatelessWidget {
  final Map<String, Map<String, dynamic>> countsWithChange;
  final bool isLoading; // Global loading (kept for backwards compatibility)

  // ✅ Individual loading states for progressive loading
  final LoadingStatus? substratesLoadingStatus;
  final LoadingStatus? alertsLoadingStatus;
  final LoadingStatus? cyclesLoadingStatus;
  final LoadingStatus? reportsLoadingStatus;

  const StatsCardRow({
    super.key,
    required this.countsWithChange,
    this.isLoading = false,
    this.substratesLoadingStatus,
    this.alertsLoadingStatus,
    this.cyclesLoadingStatus,
    this.reportsLoadingStatus,
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
            iconColor: WebColors.substratesIcon,
            backgroundColor: WebColors.substratesBackground,
            changeText: '-100%', 
            subtext: 'added substrate this month',
            isPositive: false, 
            
            isLoading:
                substratesLoadingStatus == LoadingStatus.loading ||
                (substratesLoadingStatus == null && isLoading),
          ),
        ),
        const SizedBox(width: 16),

        // Alerts Card
        Expanded(
          child: BaseStatsCard(
            title: 'Alerts',
            value: countsWithChange['alerts']?['count'] ?? 0,
            icon: Icons.warning_amber_rounded,
            iconColor: WebColors.alertsIcon,
            backgroundColor: WebColors.alertsBackground,
            changeText: countsWithChange['alerts']?['change'],
            subtext: 'last 2 days',
            isPositive: countsWithChange['alerts']?['isPositive'],
            
            isLoading:
                alertsLoadingStatus == LoadingStatus.loading ||
                (alertsLoadingStatus == null && isLoading),
          ),
        ),
        const SizedBox(width: 16),

        // Operations & AI Card
        Expanded(
          child: BaseStatsCard(
            title: 'Operations & AI',
            value: countsWithChange['operations']?['count'] ?? 0,
            icon: Icons.lightbulb_outline,
            iconColor: WebColors.operationsIcon,
            backgroundColor: WebColors.operationsBackground,
            changeText: countsWithChange['operations']?['change'],
            subtext: 'last 2 days',
            isPositive: countsWithChange['operations']?['isPositive'],
            isLoading:
                cyclesLoadingStatus == LoadingStatus.loading ||
                (cyclesLoadingStatus == null && isLoading),
          ),
        ),
        const SizedBox(width: 16),

        // Reports Card
        Expanded(
          child: BaseStatsCard(
            title: 'Reports',
            value: countsWithChange['reports']?['count'] ?? 0,
            icon: Icons.description_outlined,
            iconColor: WebColors.reportsIcon,
            backgroundColor: WebColors.reportsBackground,
            changeText: '-100%', 
            subtext: 'new reports this month',
            isPositive: false, 
          
            isLoading:
                reportsLoadingStatus == LoadingStatus.loading ||
                (reportsLoadingStatus == null && isLoading),
          ),
        ),
      ],
    );
  }
}
