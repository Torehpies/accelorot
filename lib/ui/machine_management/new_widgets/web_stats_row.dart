// lib/ui/machine_management/new_widgets/web_stats_row.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/widgets/base_stats_card.dart';
import '../../core/themes/web_colors.dart';
import '../view_model/machine_viewmodel.dart';
import '../../activity_logs/models/activity_common.dart';


/// Stats row showing: Total, Active, Archived, Suspended with MoM changes
class MachineStatsRow extends ConsumerWidget {
  const MachineStatsRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(machineViewModelProvider);
    final isLoading = viewModel.status == LoadingStatus.loading;
    
    // Get stats with month-over-month changes
    final statsWithChange = ref.read(machineViewModelProvider.notifier)
        .getMachineStatsWithChange();

    return Row(
      children: [
        // Total Machines Card
        Expanded(
          child: BaseStatsCard(
            title: 'Total Machines',
            value: statsWithChange['total']?['count'] ?? 0,
            icon: Icons.precision_manufacturing_outlined,
            iconColor: WebColors.info,
            backgroundColor: const Color(0xFFDBEAFE), // blue-100
            changeText: statsWithChange['total']?['change'],
            subtext: '${statsWithChange['total']?['changeType']} this month',
            isPositive: statsWithChange['total']?['isPositive'],
            isLoading: isLoading,
          ),
        ),
        const SizedBox(width: 16),
        
        // Active Machines Card
        Expanded(
          child: BaseStatsCard(
            title: 'Active Machines',
            value: statsWithChange['active']?['count'] ?? 0,
            icon: Icons.check_circle_outline,
            iconColor: WebColors.success,
            backgroundColor: const Color(0xFFD1FAE5), // green-100
            changeText: statsWithChange['active']?['change'],
            subtext: '${statsWithChange['active']?['changeType']} this month',
            isPositive: statsWithChange['active']?['isPositive'],
            isLoading: isLoading,
          ),
        ),
        const SizedBox(width: 16),
        
        // Archived Machines Card
        Expanded(
          child: BaseStatsCard(
            title: 'Archived Machines',
            value: statsWithChange['archived']?['count'] ?? 0,
            icon: Icons.archive_outlined,
            iconColor: WebColors.warning,
            backgroundColor: const Color(0xFFFEF3C7), // yellow-100
            changeText: statsWithChange['archived']?['change'],
            subtext: '${statsWithChange['archived']?['changeType']} this month',
            isPositive: statsWithChange['archived']?['isPositive'],
            isLoading: isLoading,
          ),
        ),
        const SizedBox(width: 16),
        
        // Suspended Machines Card
        Expanded(
          child: BaseStatsCard(
            title: 'Suspended Machines',
            value: statsWithChange['suspended']?['count'] ?? 0,
            icon: Icons.build_circle_outlined,
            iconColor: WebColors.error,
            backgroundColor: const Color(0xFFFEE2E2), // red-100
            changeText: statsWithChange['suspended']?['change'],
            subtext: '${statsWithChange['suspended']?['changeType']} this month',
            isPositive: statsWithChange['suspended']?['isPositive'],
            isLoading: isLoading,
          ),
        ),
      ],
    );
  }
}