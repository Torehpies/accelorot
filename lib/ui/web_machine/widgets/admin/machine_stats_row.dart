// lib/ui/machine_management/widgets/admin/stats/machine_stats_row.dart

import 'package:flutter/material.dart';
import '../admin/web_machine_stat_card.dart';
import '../../../core/themes/web_colors.dart';

class MachineStatsRow extends StatelessWidget {
  final int activeCount;
  final int archivedCount;
  final int newCount;

  const MachineStatsRow({
    super.key,
    required this.activeCount,
    required this.archivedCount,
    required this.newCount,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: MachineStatCard(
            title: 'Active Machines',
            count: activeCount,
            percentage: '+25%',
            subtitle: 'activated this month',
            icon: Icons.check_circle_outline,
            iconColor: WebColors.success,
            iconBgColor: WebColors.substratesBackground,
            isPositive: true,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: MachineStatCard(
            title: 'Archived Machines',
            count: archivedCount,
            percentage: '-10%',
            subtitle: 'archived this month',
            icon: Icons.archive_outlined,
            iconColor: WebColors.error,
            iconBgColor: const Color(0xFFFEE2E2),
            isPositive: false,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: MachineStatCard(
            title: 'New Machines',
            count: newCount,
            percentage: '+5%',
            subtitle: 'added this month',
            icon: Icons.add_circle_outline,
            iconColor: WebColors.info,
            iconBgColor: WebColors.operationsBackground,
            isPositive: true,
          ),
        ),
      ],
    );
  }
}