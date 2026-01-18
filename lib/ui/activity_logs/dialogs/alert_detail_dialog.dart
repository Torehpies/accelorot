// lib/ui/activity_logs/dialogs/alert_detail_dialog.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/models/alert.dart';
import '../../core/dialog/base_dialog.dart';
import '../../core/dialog/dialog_action.dart';
import '../../core/dialog/dialog_fields.dart';

class AlertDetailDialog extends StatelessWidget {
  final Alert alert;

  const AlertDetailDialog({
    super.key,
    required this.alert,
  });

  @override
  Widget build(BuildContext context) {
    final hasAdditionalReadings = alert.readings != null && alert.readings!.isNotEmpty;
    
    return BaseDialog(
      title: 'View Alert',
      subtitle: 'Sensor alert details.',
      maxHeightFactor: 0.7,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Main alert information in gray section
          ReadOnlySection(
            fields: [
              ReadOnlyField(
                label: 'Sensor Type',
                value: _formatSensorType(alert.sensorType),
              ),
              ReadOnlyField(
                label: 'Machine ID',
                value: alert.machineId,
                copyable: true,
              ),
              ReadOnlyField(
                label: 'Reading Value',
                value: alert.readingValue.toStringAsFixed(2),
              ),
              ReadOnlyField(
                label: 'Threshold',
                value: alert.threshold.toStringAsFixed(2),
              ),
              ReadOnlyField(
                label: 'Status',
                value: alert.status.toUpperCase(),
              ),
              ReadOnlyField(
                label: 'Timestamp',
                value: DateFormat('MM/dd/yyyy, hh:mm a').format(alert.timestamp),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Message (outside gray box for emphasis)
          ReadOnlyMultilineField(
            label: 'Message',
            value: alert.message,
          ),
          
          // Additional readings section
          if (hasAdditionalReadings) ...[
            const SizedBox(height: 16),
            ReadOnlySection(
              sectionTitle: 'Additional Readings',
              fields: alert.readings!.entries.map((entry) {
                return ReadOnlyField(
                  label: _formatKey(entry.key),
                  value: entry.value.toString(),
                );
              }).toList(),
            ),
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