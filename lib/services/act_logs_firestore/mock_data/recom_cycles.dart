import 'package:flutter/material.dart';
import '../../../frontend/operator/activity_logs/models/activity_item.dart';
import '../../mock_data_service.dart';

final List<ActivityItem> cyclesRecom = [
  // Today (Day 0)
  ActivityItem(
    title: 'Warning: Low Moisture Detected',
    value: '2.5kg',
    statusColor: 'red',
    icon: Icons.warning,
    description:
        'Carbon and nitrogen levels need adjustment. Add water to maintain optimal moisture levels.',
    category: 'Recoms',
    timestamp: MockDataService.daysAgo(0, hour: 11, minute: 15),
  ),

  // 1 Day Ago
  ActivityItem(
    title: 'Cycle Started',
    value: '15min',
    statusColor: 'green',
    icon: Icons.play_circle,
    description: 'Started 1st cycle of the day',
    category: 'Cycles',
    timestamp: MockDataService.daysAgo(1, hour: 9, minute: 0),
  ),

  // 2 Days Ago
  ActivityItem(
    title: 'Tip: Add More Browns',
    value: '1.8kg',
    statusColor: 'yellow',
    icon: Icons.lightbulb,
    description:
        'Balance your greens with more brown materials like dried leaves or cardboard to optimize decomposition.',
    category: 'Recoms',
    timestamp: MockDataService.daysAgo(2, hour: 14, minute: 30),
  ),

  // 3 Days Ago
  ActivityItem(
    title: 'Cycle Completed',
    value: '2hr 30min',
    statusColor: 'green',
    icon: Icons.check_circle,
    description: 'Completed 3rd cycle. Temperature optimal, moisture balanced.',
    category: 'Cycles',
    timestamp: MockDataService.daysAgo(3, hour: 16, minute: 45),
  ),

  // 4 Days Ago
  ActivityItem(
    title: 'Good: Optimal Temperature',
    value: '3.2kg',
    statusColor: 'green',
    icon: Icons.thumb_up,
    description:
        'Temperature is in the ideal range (35-40°C). Continue current maintenance routine.',
    category: 'Recoms',
    timestamp: MockDataService.daysAgo(4, hour: 10, minute: 20),
  ),

  // 5 Days Ago
  ActivityItem(
    title: 'Cycle Paused',
    value: '45min',
    statusColor: 'yellow',
    icon: Icons.pause_circle,
    description:
        'Cycle paused due to high temperature reading. Cooling down in progress.',
    category: 'Cycles',
    timestamp: MockDataService.daysAgo(5, hour: 13, minute: 15),
  ),

  // 6 Days Ago
  ActivityItem(
    title: 'Tip: Increase Aeration',
    value: '0.5kg',
    statusColor: 'grey',
    icon: Icons.air,
    description:
        'Turn the compost pile to improve oxygen flow and speed up decomposition.',
    category: 'Recoms',
    timestamp: MockDataService.daysAgo(6, hour: 8, minute: 30),
  ),
];
