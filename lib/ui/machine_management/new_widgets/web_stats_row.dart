// lib/ui/machine_management/new_widgets/web_stats_row.dart

import 'package:flutter/material.dart';
import '../../core/widgets/base_stats_card.dart';
import '../../core/themes/web_colors.dart';
import '../../../data/models/machine_model.dart';

/// Stats row showing: Total, Active, Archived, Suspended
class MachineStatsRow extends StatelessWidget {
  final List<MachineModel> machines;
  final bool isLoading;

  const MachineStatsRow({
    super.key,
    required this.machines,
    this.isLoading = false,
  });

  Map<String, int> get _stats {
    final total = machines.length;
    
    // Active = status is active only
    final active = machines.where((m) => 
      m.status == MachineStatus.active
    ).length;
    
    // Archived = isArchived flag is true
    final archived = machines.where((m) => m.isArchived).length;
    
    // Suspended = status is underMaintenance only
    final suspended = machines.where((m) => 
      m.status == MachineStatus.underMaintenance
    ).length;

    return {
      'total': total,
      'active': active,
      'archived': archived,
      'suspended': suspended,
    };
  }

  @override
  Widget build(BuildContext context) {
    final stats = _stats;

    return Row(
      children: [
        // Total Machines Card
        Expanded(
          child: BaseStatsCard(
            title: 'Total Machines',
            value: stats['total'] ?? 0,
            icon: Icons.precision_manufacturing_outlined,
            iconColor: WebColors.info,
            backgroundColor: const Color(0xFFDBEAFE), // blue-100
            changeText: null,
            subtext: 'total machines',
            isLoading: isLoading,
          ),
        ),
        const SizedBox(width: 16),
        
        // Active Machines Card
        Expanded(
          child: BaseStatsCard(
            title: 'Active Machines',
            value: stats['active'] ?? 0,
            icon: Icons.check_circle_outline,
            iconColor: WebColors.success,
            backgroundColor: const Color(0xFFD1FAE5), // green-100
            changeText: null,
            subtext: 'active machines',
            isLoading: isLoading,
          ),
        ),
        const SizedBox(width: 16),
        
        // Archived Machines Card (inactive)
        Expanded(
          child: BaseStatsCard(
            title: 'Archived Machines',
            value: stats['archived'] ?? 0,
            icon: Icons.archive_outlined,
            iconColor: WebColors.warning,
            backgroundColor: const Color(0xFFFEF3C7), // yellow-100
            changeText: null,
            subtext: 'archived machines',
            isLoading: isLoading,
          ),
        ),
        const SizedBox(width: 16),
        
        // Suspended Machines Card (under maintenance)
        Expanded(
          child: BaseStatsCard(
            title: 'Suspended Machines',
            value: stats['suspended'] ?? 0,
            icon: Icons.build_circle_outlined,
            iconColor: WebColors.error,
            backgroundColor: const Color(0xFFFEE2E2), // red-100
            changeText: null,
            subtext: 'under maintenance',
            isLoading: isLoading,
          ),
        ),
      ],
    );
  }
}