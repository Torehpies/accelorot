import 'package:flutter/material.dart';
import '../widgets/slide_page_route.dart';
import '../widgets/filter_section.dart';
import '../widgets/activity_card.dart';
import '../models/activity_item.dart';
import 'substrates_screen.dart';
import 'alerts_screen.dart';

class AllActivityScreen extends StatefulWidget {
  const AllActivityScreen({super.key});

  @override
  State<AllActivityScreen> createState() => _AllActivityScreenState();
}

class _AllActivityScreenState extends State<AllActivityScreen> {
  String selectedFilter = 'All';
  final filters = const ['All', 'Substrate', 'Alerts'];

  void _onFilterChanged(String filter) {
    setState(() => selectedFilter = filter);

    // Navigate to specific screens when filter is selected
    if (filter == 'Substrate') {
      Navigator.of(context).push(
        SlidePageRoute(page: const SubstratesScreen()),
      );
    } else if (filter == 'Alerts') {
      Navigator.of(context).push(
        SlidePageRoute(page: const AlertsScreen()),
      );
    }
    // If 'All' is selected, stay on this screen
  }

  // Mock data - mix of substrates and alerts
  List<ActivityItem> get _mockAllActivities => [
        ActivityItem(
          title: 'High Temperature',
          value: '42°C',
          statusColor: 'red',
          icon: Icons.thermostat,
          description: 'Temperature exceeded threshold of 40°C',
          category: 'Temp Alert',
          timestamp: DateTime(2024, 8, 25, 13, 45),
        ),
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
          title: 'Low Moisture',
          value: '25%',
          statusColor: 'yellow',
          icon: Icons.water_drop,
          description: 'Moisture dropped below optimal level of 30%',
          category: 'Moisture Alert',
          timestamp: DateTime(2024, 8, 25, 10, 20),
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
          title: 'Temperature Maintained',
          value: '35°C',
          statusColor: 'green',
          icon: Icons.thermostat,
          description: 'Temperature within optimal range (30-40°C)',
          category: 'Temp Alert',
          timestamp: DateTime(2024, 8, 24, 16, 30),
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
          title: 'High Humidity',
          value: '85%',
          statusColor: 'yellow',
          icon: Icons.air,
          description: 'Humidity exceeded threshold of 80%',
          category: 'Humidity Alert',
          timestamp: DateTime(2024, 8, 24, 9, 15),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text("All Activity Logs"),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Fixed filter section at top
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: FilterSection(
                  filters: filters,
                  initialFilter: selectedFilter,
                  onSelected: _onFilterChanged,
                ),
              ),

              // Scrollable cards list
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _mockAllActivities.length,
                  itemBuilder: (context, index) {
                    return ActivityCard(item: _mockAllActivities[index]);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}