import 'package:flutter/material.dart';
import '../widgets/filter_section.dart';
import '../widgets/activity_card.dart';
import '../models/activity_item.dart';

class AlertsScreen extends StatefulWidget {
  final String initialFilter;

  const AlertsScreen({
    super.key,
    this.initialFilter = 'All',
  });

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  late String selectedFilter;
  final filters = const ['All', 'Temp', 'Moisture', 'Humidity'];

  @override
  void initState() {
    super.initState();
    selectedFilter = widget.initialFilter;
  }

  void _onFilterChanged(String filter) {
    setState(() {
      selectedFilter = filter;
    });
    // TODO: Add your filtering logic here
  }

  // Mock data for alerts
  List<ActivityItem> get _mockAlerts => [
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text("Alerts Logs"),
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
                  itemCount: _mockAlerts.length,
                  itemBuilder: (context, index) {
                    return ActivityCard(item: _mockAlerts[index]);
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