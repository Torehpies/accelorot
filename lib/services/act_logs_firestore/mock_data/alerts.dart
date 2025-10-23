import 'package:flutter/material.dart';
import '../../../frontend/operator/activity_logs/models/activity_item.dart';
import '../../mock_data_service.dart';

final List<ActivityItem> alerts = [
  // Today (Day 0)
  ActivityItem(
    title: 'High Temperature',
    value: '43°C',
    statusColor: 'red',
    icon: Icons.thermostat,
    description: 'Temperature exceeded threshold of 40°C',
    category: 'Temp',
    timestamp: MockDataService.daysAgo(0, hour: 15, minute: 20),
  ),
  ActivityItem(
    title: 'Moisture Optimal',
    value: '58%',
    statusColor: 'green',
    icon: Icons.water_drop,
    description: 'Moisture maintained within range (50-60%)',
    category: 'Moisture',
    timestamp: MockDataService.daysAgo(0, hour: 10, minute: 10),
  ),

  // 1 Day Ago
  ActivityItem(
    title: 'Low Moisture',
    value: '28%',
    statusColor: 'yellow',
    icon: Icons.water_drop,
    description: 'Moisture dropped below optimal level of 30%',
    category: 'Moisture',
    timestamp: MockDataService.daysAgo(1, hour: 14, minute: 30),
  ),
  ActivityItem(
    title: 'Temperature Maintained',
    value: '36°C',
    statusColor: 'green',
    icon: Icons.thermostat,
    description: 'Temperature within optimal range (30-40°C)',
    category: 'Temp',
    timestamp: MockDataService.daysAgo(1, hour: 9, minute: 0),
  ),

  // 2 Days Ago
  ActivityItem(
    title: 'High Oxygen',
    value: '88%',
    statusColor: 'yellow',
    icon: Icons.bubble_chart,
    description: 'Oxygen level exceeded threshold of 80%',
    category: 'Oxygen',
    timestamp: MockDataService.daysAgo(2, hour: 16, minute: 45),
  ),
  ActivityItem(
    title: 'Temperature Maintained',
    value: '34°C',
    statusColor: 'green',
    icon: Icons.thermostat,
    description: 'Temperature within optimal range (30-40°C)',
    category: 'Temp',
    timestamp: MockDataService.daysAgo(2, hour: 11, minute: 15),
  ),

  // 3 Days Ago
  ActivityItem(
    title: 'Moisture Optimal',
    value: '55%',
    statusColor: 'green',
    icon: Icons.water_drop,
    description: 'Moisture maintained within range (50-60%)',
    category: 'Moisture',
    timestamp: MockDataService.daysAgo(3, hour: 13, minute: 30),
  ),
  ActivityItem(
    title: 'Temperature Drop',
    value: '27°C',
    statusColor: 'yellow',
    icon: Icons.thermostat,
    description: 'Temperature dropped below optimal range',
    category: 'Temp',
    timestamp: MockDataService.daysAgo(3, hour: 7, minute: 45),
  ),

  // 4 Days Ago
  ActivityItem(
    title: 'High Temperature',
    value: '41°C',
    statusColor: 'red',
    icon: Icons.thermostat,
    description: 'Temperature slightly above threshold',
    category: 'Temp',
    timestamp: MockDataService.daysAgo(4, hour: 15, minute: 0),
  ),
  ActivityItem(
    title: 'Low Moisture',
    value: '26%',
    statusColor: 'yellow',
    icon: Icons.water_drop,
    description: 'Moisture needs attention',
    category: 'Moisture',
    timestamp: MockDataService.daysAgo(4, hour: 10, minute: 20),
  ),

  // 5 Days Ago
  ActivityItem(
    title: 'High Oxygen',
    value: '82%',
    statusColor: 'yellow',
    icon: Icons.bubble_chart,
    description: 'Oxygen level slightly elevated',
    category: 'Oxygen',
    timestamp: MockDataService.daysAgo(5, hour: 14, minute: 15),
  ),
  ActivityItem(
    title: 'Temperature Maintained',
    value: '35°C',
    statusColor: 'green',
    icon: Icons.thermostat,
    description: 'Temperature stable and optimal',
    category: 'Temp',
    timestamp: MockDataService.daysAgo(5, hour: 8, minute: 30),
  ),

  // 6 Days Ago
  ActivityItem(
    title: 'Moisture Optimal',
    value: '52%',
    statusColor: 'green',
    icon: Icons.water_drop,
    description: 'Moisture levels perfect',
    category: 'Moisture',
    timestamp: MockDataService.daysAgo(6, hour: 16, minute: 0),
  ),
  ActivityItem(
    title: 'Temperature Maintained',
    value: '33°C',
    statusColor: 'green',
    icon: Icons.thermostat,
    description: 'Temperature within optimal range',
    category: 'Temp',
    timestamp: MockDataService.daysAgo(6, hour: 10, minute: 45),
  ),
];
