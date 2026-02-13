// lib/ui/activity_logs/bottom_sheets/mobile_cycle_detail_sheet.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/models/cycle_recommendation.dart';
import '../../core/widgets/bottom_sheets/mobile_bottom_sheet_base.dart';
import '../../core/widgets/bottom_sheets/mobile_bottom_sheet_buttons.dart';
import '../../core/widgets/bottom_sheets/fields/mobile_readonly_field.dart';
import '../../core/widgets/bottom_sheets/fields/mobile_readonly_section.dart';

class MobileCycleDetailSheet extends StatelessWidget {
  final CycleRecommendation cycle;

  const MobileCycleDetailSheet({super.key, required this.cycle});

  @override
  Widget build(BuildContext context) {
    final isRecommendation = cycle.category.toLowerCase() == 'recoms';

    return MobileBottomSheetBase(
      title: cycle.title,
      subtitle: isRecommendation ? 'AI Recommendation Details' : 'Cycle Details',
      actions: [
        BottomSheetAction.secondary(
          label: 'Close',
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
      body: MobileReadOnlySection(
        fields: [
          MobileReadOnlyField(
            label: 'Category',
            value: cycle.category,
          ),
          MobileReadOnlyField(
            label: 'Controller Type',
            value: _formatControllerType(cycle.controllerType),
          ),
          if (cycle.machineId != null)
            MobileReadOnlyField(
              label: 'Machine ID',
              value: cycle.machineId!,
            ),
          if (cycle.cycles != null)
            MobileReadOnlyField(
              label: 'Cycles',
              value: '${cycle.cycles} cycles',
            ),
          if (cycle.duration != null)
            MobileReadOnlyField(
              label: 'Duration',
              value: cycle.duration!,
            ),
          if (cycle.completedCycles != null)
            MobileReadOnlyField(
              label: 'Completed Cycles',
              value: '${cycle.completedCycles}',
            ),
          if (cycle.status != null)
            MobileReadOnlyField(
              label: 'Status',
              value: cycle.status!.toUpperCase(),
            ),
          if (cycle.totalRuntimeSeconds != null)
            MobileReadOnlyField(
              label: 'Total Runtime',
              value: _formatRuntime(cycle.totalRuntimeSeconds!),
            ),
          MobileReadOnlyField(
            label: 'Description',
            value: cycle.description,
          ),
          if (cycle.startedAt != null)
            MobileReadOnlyField(
              label: 'Started At',
              value: DateFormat('MM/dd/yyyy, hh:mm a').format(cycle.startedAt!),
            ),
          if (cycle.completedAt != null)
            MobileReadOnlyField(
              label: 'Completed At',
              value: DateFormat(
                'MM/dd/yyyy, hh:mm a',
              ).format(cycle.completedAt!),
            ),
          if (cycle.batchId != null)
            MobileReadOnlyField(
              label: 'Batch ID',
              value: cycle.batchId!,
            ),
        ],
      ),
    );
  }

  String _formatControllerType(String type) {
    switch (type) {
      case 'drum_controller':
        return 'Drum Controller';
      case 'aerator':
        return 'Aerator';
      default:
        return type
            .split('_')
            .map((word) => word[0].toUpperCase() + word.substring(1))
            .join(' ');
    }
  }

  String _formatRuntime(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;

    if (hours > 0) return '${hours}h ${minutes}m ${secs}s';
    if (minutes > 0) return '${minutes}m ${secs}s';
    return '${secs}s';
  }
}