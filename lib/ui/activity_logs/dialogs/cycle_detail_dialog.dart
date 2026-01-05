// lib/ui/activity_logs/dialogs/cycle_detail_dialog.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/models/cycle_recommendation.dart';
import '../../core/dialog/base_dialog.dart';
import '../../core/dialog/dialog_action.dart';
import '../../core/dialog/dialog_fields.dart';

class CycleDetailDialog extends StatelessWidget {
  final CycleRecommendation cycle;

  const CycleDetailDialog({
    super.key,
    required this.cycle,
  });

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
          ReadOnlyField(label: 'Title:', value: cycle.title),
          const SizedBox(height: 16),
          
          ReadOnlyField(label: 'Category:', value: cycle.category),
          const SizedBox(height: 16),
          
          ReadOnlyField(
            label: 'Controller Type:', 
            value: _formatControllerType(cycle.controllerType),
          ),
          const SizedBox(height: 16),
          
          if (cycle.machineId != null) ...[
            ReadOnlyField(label: 'Machine ID:', value: cycle.machineId!),
            const SizedBox(height: 16),
          ],
          
          if (cycle.cycles != null) ...[
            ReadOnlyField(
              label: 'Cycles:', 
              value: '${cycle.cycles} cycles',
            ),
            const SizedBox(height: 16),
          ],
          
          if (cycle.duration != null) ...[
            ReadOnlyField(label: 'Duration:', value: cycle.duration!),
            const SizedBox(height: 16),
          ],
          
          if (cycle.completedCycles != null) ...[
            ReadOnlyField(
              label: 'Completed Cycles:', 
              value: '${cycle.completedCycles}',
            ),
            const SizedBox(height: 16),
          ],
          
          if (cycle.status != null) ...[
            ReadOnlyField(
              label: 'Status:', 
              value: cycle.status!.toUpperCase(),
            ),
            const SizedBox(height: 16),
          ],
          
          if (cycle.totalRuntimeSeconds != null) ...[
            ReadOnlyField(
              label: 'Total Runtime:', 
              value: _formatRuntime(cycle.totalRuntimeSeconds!),
            ),
            const SizedBox(height: 16),
          ],
          
          ReadOnlyMultilineField(
            label: 'Description:',
            value: cycle.description,
          ),
          
          if (cycle.startedAt != null) ...[
            const SizedBox(height: 16),
            ReadOnlyField(
              label: 'Started At:',
              value: DateFormat('MM/dd/yyyy, hh:mm a').format(cycle.startedAt!),
            ),
          ],
          
          if (cycle.completedAt != null) ...[
            const SizedBox(height: 16),
            ReadOnlyField(
              label: 'Completed At:',
              value: DateFormat('MM/dd/yyyy, hh:mm a').format(cycle.completedAt!),
            ),
          ],
          
          if (cycle.timestamp != null) ...[
            const SizedBox(height: 16),
            ReadOnlyField(
              label: 'Date Added:',
              value: DateFormat('MM/dd/yyyy, hh:mm a').format(cycle.timestamp!),
            ),
          ],
          
          if (cycle.batchId != null) ...[
            const SizedBox(height: 16),
            ReadOnlyField(label: 'Batch ID:', value: cycle.batchId!),
          ],
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