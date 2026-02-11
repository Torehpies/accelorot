// lib/ui/activity_logs/dialogs/cycle_detail_dialog.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/models/cycle_recommendation.dart';
import '../../core/widgets/dialog/base_dialog.dart';
import '../../core/widgets/dialog/dialog_action.dart';
import '../../core/widgets/dialog/dialog_fields.dart';

class CycleDetailDialog extends StatelessWidget {
  final CycleRecommendation cycle;

  const CycleDetailDialog({super.key, required this.cycle});

  @override
  Widget build(BuildContext context) {
    final isRecommendation = cycle.category.toLowerCase() == 'recoms';

    return BaseDialog(
      title: isRecommendation ? 'View Recommendation' : 'View Cycle',
      subtitle: isRecommendation
          ? 'View in-depth information about this AI recommendation.'
          : 'View in-depth information about this composting cycle.',
      maxHeightFactor: 0.7,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // All cycle information in one gray section
          ReadOnlySection(
            fields: [
              ReadOnlyField(label: 'Title', value: cycle.title),
              ReadOnlyField(label: 'Category', value: cycle.category),
              ReadOnlyField(
                label: 'Controller Type',
                value: _formatControllerType(cycle.controllerType),
              ),
              if (cycle.machineId != null)
                ReadOnlyField(label: 'Machine ID', value: cycle.machineId!),
              if (cycle.cycles != null)
                ReadOnlyField(label: 'Cycles', value: '${cycle.cycles} cycles'),
              if (cycle.duration != null)
                ReadOnlyField(label: 'Duration', value: cycle.duration!),
              if (cycle.completedCycles != null)
                ReadOnlyField(
                  label: 'Completed Cycles',
                  value: '${cycle.completedCycles}',
                ),
              if (cycle.status != null)
                ReadOnlyField(
                  label: 'Status',
                  value: cycle.status!.toUpperCase(),
                ),
              if (cycle.totalRuntimeSeconds != null)
                ReadOnlyField(
                  label: 'Total Runtime',
                  value: _formatRuntime(cycle.totalRuntimeSeconds!),
                ),

              // Description as multiline field
              ReadOnlyMultilineField(
                label: 'Description',
                value: cycle.description,
              ),

              // Started At and Completed At (special for cycles)
              if (cycle.startedAt != null)
                ReadOnlyField(
                  label: 'Started At',
                  value: DateFormat(
                    'MM/dd/yyyy, hh:mm a',
                  ).format(cycle.startedAt!),
                ),
              if (cycle.completedAt != null)
                ReadOnlyField(
                  label: 'Completed At',
                  value: DateFormat(
                    'MM/dd/yyyy, hh:mm a',
                  ).format(cycle.completedAt!),
                ),

              // Batch ID if available
              if (cycle.batchId != null)
                ReadOnlyField(label: 'Batch ID', value: cycle.batchId!),
            ],
          ),
        ],
      ),
      actions: [
        DialogAction.secondary(
          label: 'Close',
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }

  /// Format controller type for display
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

  /// Format runtime seconds to human-readable format
  String _formatRuntime(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m ${secs}s';
    } else if (minutes > 0) {
      return '${minutes}m ${secs}s';
    } else {
      return '${secs}s';
    }
  }
}
