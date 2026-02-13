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
          // Only show readings relevant to this sensor type
          if (alert.readings != null && alert.readings!.isNotEmpty)
            ..._getRelevantReadings().map(
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

  /// Filter readings to only show ones relevant to the current sensor type
  List<MapEntry<String, dynamic>> _getRelevantReadings() {
    if (alert.readings == null || alert.readings!.isEmpty) {
      return [];
    }

    final sensorType = alert.sensorType.toLowerCase();
    final allReadings = alert.readings!.entries.toList();

    // Filter based on sensor type
    return allReadings.where((entry) {
      final key = entry.key.toLowerCase();

      switch (sensorType) {
        case 'temperature':
        case 'temp':
          return key.contains('temp') || key.contains('temperature');
        
        case 'oxygen':
        case 'o2':
          return key.contains('oxygen') || key.contains('o2');
        
        case 'moisture':
        case 'humidity':
          return key.contains('moisture') || key.contains('humidity');
        
        case 'ph':
          return key.contains('ph');
        
        case 'pressure':
          return key.contains('pressure');
        
        case 'co2':
        case 'carbon_dioxide':
          return key.contains('co2') || key.contains('carbon');
        
        default:
          // If unknown sensor type, show all readings (fallback)
          return true;
      }
    }).toList();
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