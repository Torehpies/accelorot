import 'package:flutter/material.dart';

class AlertsScreen extends StatefulWidget {
  final String initialFilter;

  const AlertsScreen({
    super.key,
    this.initialFilter = 'All', // default
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
                itemCount: 6,
                itemBuilder: (context, index) {
                  return Card(
                    elevation: 3,
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: const Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.teal,
                      ),
                      title: Text("Alert #${index + 1}"),
                      subtitle: Text(
                        selectedFilter == 'All'
                            ? "General Alert"
                            : "$selectedFilter Alert",
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
