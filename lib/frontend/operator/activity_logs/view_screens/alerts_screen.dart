import 'package:flutter/material.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  String selectedFilter = 'All';
  final filters = const ['All', 'Temperature', 'Moisture', 'Humidity'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Alerts Logs"),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 🔹 Filter chips
            Wrap(
              spacing: 8,
              children: filters.map((filter) {
                final isSelected = selectedFilter == filter;
                return ChoiceChip(
                  label: Text(filter),
                  selected: isSelected,
                  selectedColor: Colors.teal,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                  ),
                  onSelected: (_) {
                    setState(() => selectedFilter = filter);
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 16),

            // 🔹 Scrollable list
            Expanded(
              child: ListView.builder(
                itemCount: 5,
                itemBuilder: (context, index) {
                  return Card(
                    elevation: 3,
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: Icon(
                        Icons.warning_amber_rounded,
                        color: selectedFilter == 'Temperature'
                            ? Colors.redAccent
                            : selectedFilter == 'Moisture'
                                ? Colors.blue
                                : selectedFilter == 'Humidity'
                                    ? Colors.orange
                                    : Colors.teal,
                      ),
                      title: Text("Alert #${index + 1}"),
                      subtitle: Text(
                        selectedFilter == 'All'
                            ? "General Alert"
                            : "$selectedFilter Issue",
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
