// lib/ui/activity_logs/bottom_sheets/mobile_alert_detail_sheet.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/models/alert.dart';
import '../../core/widgets/bottom_sheets/mobile_bottom_sheet_base.dart';
import '../../core/widgets/bottom_sheets/mobile_bottom_sheet_buttons.dart';
import '../../core/widgets/bottom_sheets/fields/mobile_readonly_field.dart';
import '../../core/widgets/bottom_sheets/fields/mobile_readonly_section.dart';

class MobileAlertDetailSheet extends StatelessWidget {
  final Alert alert;

  const MobileAlertDetailSheet({super.key, required this.alert});

  @override
  Widget build(BuildContext context) {
    return MobileBottomSheetBase(
      title: _formatSensorType(alert.sensorType),
      subtitle: 'Alert Details',
      actions: [
        BottomSheetAction.secondary(
          label: 'Close',
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
      body: MobileReadOnlySection(
        fields: [
          MobileReadOnlyField(
            label: 'Sensor Type',
            value: _formatSensorType(alert.sensorType),
          ),
          MobileReadOnlyField(
            label: 'Machine ID',
            value: alert.machineId,
          ),
          MobileReadOnlyField(
            label: 'Reading Value',
            value: alert.readingValue.toStringAsFixed(2),
          ),
          MobileReadOnlyField(
            label: 'Threshold',
            value: alert.threshold.toStringAsFixed(2),
          ),
          MobileReadOnlyField(
            label: 'Status',
            value: alert.status.toUpperCase(),
          ),
          MobileReadOnlyField(
            label: 'Message',
            value: alert.message,
          ),
          if (alert.readings != null && alert.readings!.isNotEmpty)
            ...alert.readings!.entries.map(
              (entry) => MobileReadOnlyField(
                label: _formatKey(entry.key),
                value: entry.value.toString(),
              ),
            ),
          MobileReadOnlyField(
            label: 'Date Added',
            value: DateFormat('MM/dd/yyyy, hh:mm a').format(alert.timestamp),
          ),
        ],
      ),
    );
  }

  String _formatSensorType(String type) {
    return type
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  String _formatKey(String key) {
    return key
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }
}