// lib/frontend/operator/activity_logs/view_screens/alerts_screen.dart
import 'package:flutter/material.dart';
import '../widgets/shared/base_activity_screen.dart';
import '../models/activity_item.dart';
import '../../../../services/firestore_alert_service.dart';

class AlertsScreen extends BaseActivityScreen {
  const AlertsScreen({
    super.key,
    super.initialFilter,
    super.viewingOperatorId,
    super.focusedMachineId
  });

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends BaseActivityScreenState<AlertsScreen> {
  @override
  String get screenTitle => widget.focusedMachineId != null
      ? 'Machine Alerts'
      : 'Alerts Logs';

  @override
  List<String> get filters => const ['All', 'Temperature', 'Moisture', 'Oxygen'];

  /// Helper function to capitalize first letter properly
  String toProperCase(String input) {
    if (input.isEmpty) return input;
    return input[0].toUpperCase() + input.substring(1).toLowerCase();
  }

  @override
  Future<List<ActivityItem>> fetchData() async {
    final batchId = widget.viewingOperatorId ?? '123456_03';
    final alerts = await FirestoreAlertService.fetchAlertsForBatch(batchId);

    final List<ActivityItem> activityList = alerts.map<ActivityItem>((alert) {
      final rawSensorType = (alert['sensor_type'] ?? '').toString();
      final sensorType = toProperCase(rawSensorType);
      final status = (alert['status'] ?? '').toString().toLowerCase();

      // Determine category and icon
      String category;
      IconData icon;
      if (sensorType.toLowerCase().contains('temp')) {
        category = 'Temperature';
        icon = Icons.thermostat;
      } else if (sensorType.toLowerCase().contains('moisture')) {
        category = 'Moisture';
        icon = Icons.water_drop;
      } else if (sensorType.toLowerCase().contains('oxygen')) {
        category = 'Oxygen';
        icon = Icons.air;
      } else {
        category = 'Other';
        icon = Icons.warning;
      }

      // Determine color based on alert status
      String color;
      if (status == 'below') {
        color = 'blue';
      } else if (status == 'above') {
        color = 'red';
      } else {
        color = 'grey';
      }

      // Proper case message
      final message = toProperCase(alert['message'] ?? 'Alert');

      return ActivityItem(
        title: message,
        value: '${alert['reading_value']}',
        statusColor: color,
        icon: icon,
        description:
            'Sensor: $sensorType\nReading: ${alert['reading_value']}\nThreshold: ${alert['threshold']} (${alert['status']})',
        category: category,
        timestamp:
            DateTime.tryParse(alert['timestamp'] ?? '') ?? DateTime.now(),
        machineId: alert['machine_id'], // ⭐ Changed from userId to machineId
      );
    }).toList();

    return activityList;
  }

  @override
  List<ActivityItem> filterByCategory(List<ActivityItem> items, String filter) {
    if (filter == 'All') return items;
    return items.where((item) => item.category == filter).toList();
  }

  @override
  Set<String> getCategoriesInSearchResults(List<ActivityItem> searchResults) {
    final categories = searchResults.map((item) => item.category).toSet();
    final specificCategories = {'Temperature', 'Moisture', 'Oxygen'};

    Set<String> result = {};
    for (var cat in specificCategories) {
      if (categories.contains(cat)) {
        result.add(cat);
      }
    }

    if (specificCategories.every((cat) => categories.contains(cat))) {
      result.add('All');
    }

    return result;
  }
}