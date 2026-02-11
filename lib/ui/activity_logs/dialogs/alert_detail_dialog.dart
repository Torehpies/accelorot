// lib/ui/activity_logs/dialogs/alert_detail_dialog.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/models/alert.dart';
import '../../core/widgets/dialog/base_dialog.dart';
import '../../core/widgets/dialog/dialog_action.dart';
import '../../core/widgets/dialog/dialog_fields.dart';

class AlertDetailDialog extends StatelessWidget {
  final Alert alert;

  const AlertDetailDialog({super.key, required this.alert});

  @override
  Widget build(BuildContext context) {
    return BaseDialog(
      title: 'View Alert',
      subtitle: 'Sensor alert details.',
      maxHeightFactor: 0.7,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // All alert information in one gray section
          ReadOnlySection(
            fields: [
              ReadOnlyField(
                label: 'Sensor Type',
                value: _formatSensorType(alert.sensorType),
              ),
              ReadOnlyField(label: 'Machine ID', value: alert.machineId),
              ReadOnlyField(
                label: 'Reading Value',
                value: alert.readingValue.toStringAsFixed(2),
              ),
              ReadOnlyField(
                label: 'Threshold',
                value: alert.threshold.toStringAsFixed(2),
              ),
              ReadOnlyField(label: 'Status', value: alert.status.toUpperCase()),

              // Message as multiline field
              ReadOnlyMultilineField(label: 'Message', value: alert.message),

              // Additional readings (if available)
              if (alert.readings != null && alert.readings!.isNotEmpty)
                ...alert.readings!.entries.map((entry) {
                  return ReadOnlyField(
                    label: _formatKey(entry.key),
                    value: entry.value.toString(),
                  );
                }),

              // Date Added (Timestamp)
              ReadOnlyField(
                label: 'Date Added',
                value: DateFormat(
                  'MM/dd/yyyy, hh:mm a',
                ).format(alert.timestamp),
              ),
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

  /// Format sensor type for display
  String _formatSensorType(String type) {
    return type
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  /// Format map key for display
  String _formatKey(String key) {
    return key
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }
}
