import 'package:flutter/material.dart';
import '../../../data/models/activity_item.dart';
import '../../mock_data_service.dart';

final List<ActivityItem> substrates = [
  // Today (Day 0)
  ActivityItem(
    title: 'Fruit Scraps Added',
    value: '1.2kg',
    statusColor: 'green',
    icon: Icons.eco,
    description: 'Kitchen scraps: apple peels, banana peel',
    category: 'Greens',
    timestamp: MockDataService.daysAgo(0, hour: 14, minute: 30),
  ),
  ActivityItem(
    title: 'Coffee Grounds Added',
    value: '0.4kg',
    statusColor: 'green',
    icon: Icons.eco,
    description: 'Morning coffee grounds from kitchen',
    category: 'Greens',
    timestamp: MockDataService.daysAgo(0, hour: 8, minute: 15),
  ),

  // 1 Day Ago
  ActivityItem(
    title: 'Dry Leaves Added',
    value: '0.9kg',
    statusColor: 'green',
    icon: Icons.energy_savings_leaf,
    description: 'Garden waste: dried leaves, small twigs',
    category: 'Browns',
    timestamp: MockDataService.daysAgo(1, hour: 16, minute: 20),
  ),
  ActivityItem(
    title: 'Vegetable Scraps Added',
    value: '1.3kg',
    statusColor: 'green',
    icon: Icons.eco,
    description: 'Carrot peels, lettuce cores, tomato ends',
    category: 'Greens',
    timestamp: MockDataService.daysAgo(1, hour: 11, minute: 45),
  ),

  // 2 Days Ago
  ActivityItem(
    title: 'Cardboard Shredded',
    value: '0.6kg',
    statusColor: 'yellow',
    icon: Icons.energy_savings_leaf,
    description: 'Packaging materials: egg cartons, boxes',
    category: 'Browns',
    timestamp: MockDataService.daysAgo(2, hour: 15, minute: 10),
  ),
  ActivityItem(
    title: 'Fruit Scraps Added',
    value: '1.0kg',
    statusColor: 'green',
    icon: Icons.eco,
    description: 'Kitchen scraps: orange peels, melon rinds',
    category: 'Greens',
    timestamp: MockDataService.daysAgo(2, hour: 9, minute: 30),
  ),

  // 3 Days Ago
  ActivityItem(
    title: 'Coffee Grounds Added',
    value: '0.3kg',
    statusColor: 'green',
    icon: Icons.eco,
    description: 'Afternoon coffee grounds from office',
    category: 'Greens',
    timestamp: MockDataService.daysAgo(3, hour: 13, minute: 0),
  ),
  ActivityItem(
    title: 'Dry Leaves Added',
    value: '1.1kg',
    statusColor: 'green',
    icon: Icons.energy_savings_leaf,
    description: 'Garden cleanup: dried leaves and grass',
    category: 'Browns',
    timestamp: MockDataService.daysAgo(3, hour: 10, minute: 15),
  ),

  // 4 Days Ago
  ActivityItem(
    title: 'Compost Ready',
    value: '5.5kg',
    statusColor: 'green',
    icon: Icons.recycling,
    description: 'Batch #13 completed decomposition',
    category: 'Compost',
    timestamp: MockDataService.daysAgo(4, hour: 14, minute: 45),
  ),
  ActivityItem(
    title: 'Vegetable Scraps Added',
    value: '1.4kg',
    statusColor: 'green',
    icon: Icons.eco,
    description: 'Potato peels, cucumber ends, pepper cores',
    category: 'Greens',
    timestamp: MockDataService.daysAgo(4, hour: 8, minute: 20),
  ),

  // 5 Days Ago
  ActivityItem(
    title: 'Cardboard Shredded',
    value: '0.7kg',
    statusColor: 'yellow',
    icon: Icons.energy_savings_leaf,
    description: 'Cereal boxes and paper towel rolls',
    category: 'Browns',
    timestamp: MockDataService.daysAgo(5, hour: 16, minute: 30),
  ),
  ActivityItem(
    title: 'Fruit Scraps Added',
    value: '1.1kg',
    statusColor: 'green',
    icon: Icons.eco,
    description: 'Kitchen scraps: pineapple core, strawberry tops',
    category: 'Greens',
    timestamp: MockDataService.daysAgo(5, hour: 12, minute: 0),
  ),

  // 6 Days Ago
  ActivityItem(
    title: 'Coffee Grounds Added',
    value: '0.5kg',
    statusColor: 'green',
    icon: Icons.eco,
    description: 'Weekend coffee grounds collection',
    category: 'Greens',
    timestamp: MockDataService.daysAgo(6, hour: 15, minute: 15),
  ),
  ActivityItem(
    title: 'Dry Leaves Added',
    value: '0.8kg',
    statusColor: 'green',
    icon: Icons.energy_savings_leaf,
    description: 'Garden waste: dried leaves from backyard',
    category: 'Browns',
    timestamp: MockDataService.daysAgo(6, hour: 9, minute: 45),
  ),
];
