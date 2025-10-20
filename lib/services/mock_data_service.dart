//mock_data_service.dart
import 'package:flutter/material.dart';
import '../frontend/operator/activity_logs/models/activity_item.dart';

class MockDataService {
  // Helper to get date X days ago
  static DateTime _daysAgo(int days, {int hour = 12, int minute = 0}) {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day - days, hour, minute);
  }

  // Static substrate data - 2 per day for last 7 days
  static final List<ActivityItem> _substrates = [
    // Today (Day 0)
    ActivityItem(
      title: 'Fruit Scraps Added',
      value: '1.2kg',
      statusColor: 'green',
      icon: Icons.eco,
      description: 'Kitchen scraps: apple peels, banana peel',
      category: 'Greens',
      timestamp: _daysAgo(0, hour: 14, minute: 30),
    ),
    ActivityItem(
      title: 'Coffee Grounds Added',
      value: '0.4kg',
      statusColor: 'green',
      icon: Icons.eco,
      description: 'Morning coffee grounds from kitchen',
      category: 'Greens',
      timestamp: _daysAgo(0, hour: 8, minute: 15),
    ),

    // 1 Day Ago
    ActivityItem(
      title: 'Dry Leaves Added',
      value: '0.9kg',
      statusColor: 'green',
      icon: Icons.energy_savings_leaf,
      description: 'Garden waste: dried leaves, small twigs',
      category: 'Browns',
      timestamp: _daysAgo(1, hour: 16, minute: 20),
    ),
    ActivityItem(
      title: 'Vegetable Scraps Added',
      value: '1.3kg',
      statusColor: 'green',
      icon: Icons.eco,
      description: 'Carrot peels, lettuce cores, tomato ends',
      category: 'Greens',
      timestamp: _daysAgo(1, hour: 11, minute: 45),
    ),

    // 2 Days Ago
    ActivityItem(
      title: 'Cardboard Shredded',
      value: '0.6kg',
      statusColor: 'yellow',
      icon: Icons.energy_savings_leaf,
      description: 'Packaging materials: egg cartons, boxes',
      category: 'Browns',
      timestamp: _daysAgo(2, hour: 15, minute: 10),
    ),
    ActivityItem(
      title: 'Fruit Scraps Added',
      value: '1.0kg',
      statusColor: 'green',
      icon: Icons.eco,
      description: 'Kitchen scraps: orange peels, melon rinds',
      category: 'Greens',
      timestamp: _daysAgo(2, hour: 9, minute: 30),
    ),

    // 3 Days Ago
    ActivityItem(
      title: 'Coffee Grounds Added',
      value: '0.3kg',
      statusColor: 'green',
      icon: Icons.eco,
      description: 'Afternoon coffee grounds from office',
      category: 'Greens',
      timestamp: _daysAgo(3, hour: 13, minute: 0),
    ),
    ActivityItem(
      title: 'Dry Leaves Added',
      value: '1.1kg',
      statusColor: 'green',
      icon: Icons.energy_savings_leaf,
      description: 'Garden cleanup: dried leaves and grass',
      category: 'Browns',
      timestamp: _daysAgo(3, hour: 10, minute: 15),
    ),

    // 4 Days Ago
    ActivityItem(
      title: 'Compost Ready',
      value: '5.5kg',
      statusColor: 'green',
      icon: Icons.recycling,
      description: 'Batch #13 completed decomposition',
      category: 'Compost',
      timestamp: _daysAgo(4, hour: 14, minute: 45),
    ),
    ActivityItem(
      title: 'Vegetable Scraps Added',
      value: '1.4kg',
      statusColor: 'green',
      icon: Icons.eco,
      description: 'Potato peels, cucumber ends, pepper cores',
      category: 'Greens',
      timestamp: _daysAgo(4, hour: 8, minute: 20),
    ),

    // 5 Days Ago
    ActivityItem(
      title: 'Cardboard Shredded',
      value: '0.7kg',
      statusColor: 'yellow',
      icon: Icons.energy_savings_leaf,
      description: 'Cereal boxes and paper towel rolls',
      category: 'Browns',
      timestamp: _daysAgo(5, hour: 16, minute: 30),
    ),
    ActivityItem(
      title: 'Fruit Scraps Added',
      value: '1.1kg',
      statusColor: 'green',
      icon: Icons.eco,
      description: 'Kitchen scraps: pineapple core, strawberry tops',
      category: 'Greens',
      timestamp: _daysAgo(5, hour: 12, minute: 0),
    ),

    // 6 Days Ago
    ActivityItem(
      title: 'Coffee Grounds Added',
      value: '0.5kg',
      statusColor: 'green',
      icon: Icons.eco,
      description: 'Weekend coffee grounds collection',
      category: 'Greens',
      timestamp: _daysAgo(6, hour: 15, minute: 15),
    ),
    ActivityItem(
      title: 'Dry Leaves Added',
      value: '0.8kg',
      statusColor: 'green',
      icon: Icons.energy_savings_leaf,
      description: 'Garden waste: dried leaves from backyard',
      category: 'Browns',
      timestamp: _daysAgo(6, hour: 9, minute: 45),
    ),
  ];

  // Static alerts data - 2 per day for last 7 days
  static final List<ActivityItem> _alerts = [
    // Today (Day 0)
    ActivityItem(
      title: 'High Temperature',
      value: '43°C',
      statusColor: 'red',
      icon: Icons.thermostat,
      description: 'Temperature exceeded threshold of 40°C',
      category: 'Temp',
      timestamp: _daysAgo(0, hour: 15, minute: 20),
    ),
    ActivityItem(
      title: 'Moisture Optimal',
      value: '58%',
      statusColor: 'green',
      icon: Icons.water_drop,
      description: 'Moisture maintained within range (50-60%)',
      category: 'Moisture',
      timestamp: _daysAgo(0, hour: 10, minute: 10),
    ),

    // 1 Day Ago
    ActivityItem(
      title: 'Low Moisture',
      value: '28%',
      statusColor: 'yellow',
      icon: Icons.water_drop,
      description: 'Moisture dropped below optimal level of 30%',
      category: 'Moisture',
      timestamp: _daysAgo(1, hour: 14, minute: 30),
    ),
    ActivityItem(
      title: 'Temperature Maintained',
      value: '36°C',
      statusColor: 'green',
      icon: Icons.thermostat,
      description: 'Temperature within optimal range (30-40°C)',
      category: 'Temp',
      timestamp: _daysAgo(1, hour: 9, minute: 0),
    ),

    // 2 Days Ago
    ActivityItem(
      title: 'High Oxygen',
      value: '88%',
      statusColor: 'yellow',
      icon: Icons.bubble_chart,
      description: 'Oxygen level exceeded threshold of 80%',
      category: 'Oxygen',
      timestamp: _daysAgo(2, hour: 16, minute: 45),
    ),
    ActivityItem(
      title: 'Temperature Maintained',
      value: '34°C',
      statusColor: 'green',
      icon: Icons.thermostat,
      description: 'Temperature within optimal range (30-40°C)',
      category: 'Temp',
      timestamp: _daysAgo(2, hour: 11, minute: 15),
    ),

    // 3 Days Ago
    ActivityItem(
      title: 'Moisture Optimal',
      value: '55%',
      statusColor: 'green',
      icon: Icons.water_drop,
      description: 'Moisture maintained within range (50-60%)',
      category: 'Moisture',
      timestamp: _daysAgo(3, hour: 13, minute: 30),
    ),
    ActivityItem(
      title: 'Temperature Drop',
      value: '27°C',
      statusColor: 'yellow',
      icon: Icons.thermostat,
      description: 'Temperature dropped below optimal range',
      category: 'Temp',
      timestamp: _daysAgo(3, hour: 7, minute: 45),
    ),

    // 4 Days Ago
    ActivityItem(
      title: 'High Temperature',
      value: '41°C',
      statusColor: 'red',
      icon: Icons.thermostat,
      description: 'Temperature slightly above threshold',
      category: 'Temp',
      timestamp: _daysAgo(4, hour: 15, minute: 0),
    ),
    ActivityItem(
      title: 'Low Moisture',
      value: '26%',
      statusColor: 'yellow',
      icon: Icons.water_drop,
      description: 'Moisture needs attention',
      category: 'Moisture',
      timestamp: _daysAgo(4, hour: 10, minute: 20),
    ),

    // 5 Days Ago
    ActivityItem(
      title: 'High Oxygen',
      value: '82%',
      statusColor: 'yellow',
      icon: Icons.bubble_chart,
      description: 'Oxygen level slightly elevated',
      category: 'Oxygen',
      timestamp: _daysAgo(5, hour: 14, minute: 15),
    ),
    ActivityItem(
      title: 'Temperature Maintained',
      value: '35°C',
      statusColor: 'green',
      icon: Icons.thermostat,
      description: 'Temperature stable and optimal',
      category: 'Temp',
      timestamp: _daysAgo(5, hour: 8, minute: 30),
    ),

    // 6 Days Ago
    ActivityItem(
      title: 'Moisture Optimal',
      value: '52%',
      statusColor: 'green',
      icon: Icons.water_drop,
      description: 'Moisture levels perfect',
      category: 'Moisture',
      timestamp: _daysAgo(6, hour: 16, minute: 0),
    ),
    ActivityItem(
      title: 'Temperature Maintained',
      value: '33°C',
      statusColor: 'green',
      icon: Icons.thermostat,
      description: 'Temperature within optimal range',
      category: 'Temp',
      timestamp: _daysAgo(6, hour: 10, minute: 45),
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