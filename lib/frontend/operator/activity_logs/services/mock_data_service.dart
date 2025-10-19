//mock_data_service.dart
import 'package:flutter/material.dart';
import '../models/activity_item.dart';

class MockDataService {
  // Static substrate data
  static final List<ActivityItem> _substrates = [
    ActivityItem(
      title: 'Fruit Scraps Added',
      value: '1.2kg',
      statusColor: 'green',
      icon: Icons.eco,
      description: 'Kitchen scraps: apple peels, banana peel',
      category: 'Greens',
      timestamp: DateTime(2024, 8, 25, 0, 12),
    ),
    ActivityItem(
      title: 'Dry Leaves Added',
      value: '0.8kg',
      statusColor: 'green',
      icon: Icons.energy_savings_leaf,
      description: 'Garden waste: dried leaves, small twigs',
      category: 'Browns',
      timestamp: DateTime(2024, 8, 24, 14, 30),
    ),
    ActivityItem(
      title: 'Coffee Grounds Added',
      value: '0.3kg',
      statusColor: 'green',
      icon: Icons.eco,
      description: 'Morning coffee grounds from kitchen',
      category: 'Greens',
      timestamp: DateTime(2024, 8, 24, 8, 15),
    ),
    ActivityItem(
      title: 'Cardboard Shredded',
      value: '0.5kg',
      statusColor: 'yellow',
      icon: Icons.energy_savings_leaf,
      description: 'Packaging materials: egg cartons, boxes',
      category: 'Browns',
      timestamp: DateTime(2024, 8, 23, 16, 45),
    ),
    ActivityItem(
      title: 'Vegetable Scraps Added',
      value: '1.5kg',
      statusColor: 'green',
      icon: Icons.eco,
      description: 'Carrot peels, lettuce cores, tomato ends',
      category: 'Greens',
      timestamp: DateTime(2024, 8, 23, 11, 20),
    ),
    ActivityItem(
      title: 'Compost Ready',
      value: '5.2kg',
      statusColor: 'green',
      icon: Icons.recycling,
      description: 'Batch #12 completed decomposition',
      category: 'Compost',
      timestamp: DateTime(2024, 8, 22, 9, 0),
    ),
  ];

  // Static alerts data
  static final List<ActivityItem> _alerts = [
    ActivityItem(
      title: 'High Temperature',
      value: '42°C',
      statusColor: 'red',
      icon: Icons.thermostat,
      description: 'Temperature exceeded threshold of 40°C',
      category: 'Temp',
      timestamp: DateTime(2024, 8, 25, 13, 45),
    ),
    ActivityItem(
      title: 'Low Moisture',
      value: '25%',
      statusColor: 'yellow',
      icon: Icons.water_drop,
      description: 'Moisture dropped below optimal level of 30%',
      category: 'Moisture',
      timestamp: DateTime(2024, 8, 25, 10, 20),
    ),
    ActivityItem(
      title: 'Temperature Maintained',
      value: '35°C',
      statusColor: 'green',
      icon: Icons.thermostat,
      description: 'Temperature within optimal range (30-40°C)',
      category: 'Temp',
      timestamp: DateTime(2024, 8, 24, 16, 30),
    ),
    ActivityItem(
      title: 'High Humidity',
      value: '85%',
      statusColor: 'yellow',
      icon: Icons.air,
      description: 'Humidity exceeded threshold of 80%',
      category: 'Humidity',
      timestamp: DateTime(2024, 8, 24, 9, 15),
    ),
    ActivityItem(
      title: 'Moisture Optimal',
      value: '55%',
      statusColor: 'green',
      icon: Icons.water_drop,
      description: 'Moisture maintained within range (50-60%)',
      category: 'Moisture',
      timestamp: DateTime(2024, 8, 23, 14, 0),
    ),
    ActivityItem(
      title: 'Temperature Drop',
      value: '28°C',
      statusColor: 'yellow',
      icon: Icons.thermostat,
      description: 'Temperature dropped below optimal range',
      category: 'Temp',
      timestamp: DateTime(2024, 8, 23, 7, 45),
    ),
  ];

  // Get all substrates
  static List<ActivityItem> getSubstrates() {
    return List.from(_substrates);
  }

  // Get all alerts
  static List<ActivityItem> getAlerts() {
    return List.from(_alerts);
  }

  // Get all activities combined and sorted by timestamp
  static List<ActivityItem> getAllActivities() {
    final combined = [..._substrates, ..._alerts];
    combined.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return combined;
  }
}