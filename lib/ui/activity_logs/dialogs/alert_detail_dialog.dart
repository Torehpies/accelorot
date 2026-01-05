// lib/ui/activity_logs/dialogs/alert_detail_dialog.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/models/alert.dart';
import '../../core/dialog/base_dialog.dart';
import '../../core/dialog/dialog_action.dart';
import '../../core/dialog/dialog_fields.dart';
import '../../core/themes/web_text_styles.dart';

class AlertDetailDialog extends StatelessWidget {
  final Alert alert;

  const AlertDetailDialog({
    super.key,
    required this.alert,
  });

  @override
  Widget build(BuildContext context) {
    return BaseDialog(
      title: 'View Alert',
      subtitle: 'Sensor alert details.',
      maxHeightFactor: 0.7,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ReadOnlyField(
            label: 'Sensor Type:', 
            value: _formatSensorType(alert.sensorType),
          ),
          const SizedBox(height: 16),
          
          ReadOnlyField(label: 'Machine ID:', value: alert.machineId),
          const SizedBox(height: 16),
          
          ReadOnlyField(
            label: 'Reading Value:',
            value: alert.readingValue.toStringAsFixed(2),
          ),
          const SizedBox(height: 16),
          
          ReadOnlyField(
            label: 'Threshold:',
            value: alert.threshold.toStringAsFixed(2),
          ),
          const SizedBox(height: 16),
          
          ReadOnlyField(
            label: 'Status:',
            value: alert.status.toUpperCase(),
          ),
          const SizedBox(height: 16),
          
          ReadOnlyMultilineField(
            label: 'Message:',
            value: alert.message,
          ),
          
          // Show additional readings if available
          if (alert.readings != null && alert.readings!.isNotEmpty) ...[
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            Text(
              'Additional Readings:',
              style: WebTextStyles.bodyMediumGray.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...alert.readings!.entries.map((entry) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ReadOnlyField(
                label: '${_formatKey(entry.key)}:',
                value: entry.value.toString(),
              ),
            )),
          ],
          
          const SizedBox(height: 16),
          ReadOnlyField(
            label: 'Timestamp:',
            value: DateFormat('MM/dd/yyyy, hh:mm a').format(alert.timestamp),
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