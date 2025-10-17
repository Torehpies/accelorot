import 'package:flutter/material.dart';
import '../widgets/slide_page_route.dart';
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

  void onFilterSelected(String filter) {
    setState(() => selectedFilter = filter);

    if (filter == 'Substrate') {
      Navigator.of(context).push(
        SlidePageRoute(page: const SubstratesScreen()),
      );
    } else if (filter == 'Alerts') {
      Navigator.of(context).push(
        SlidePageRoute(page: const AlertsScreen()),
      );
    }
  }

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
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Wrap(
              spacing: 8,
              children: filters.map((filter) {
                final isSelected = filter == selectedFilter;
                return ChoiceChip(
                  label: Text(filter),
                  selected: isSelected,
                  selectedColor: Colors.teal,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                  ),
                  onSelected: (_) => onFilterSelected(filter),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: 8,
                itemBuilder: (context, index) {
                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: const Icon(Icons.history, color: Colors.teal),
                      title: Text("Activity #${index + 1}"),
                      subtitle: const Text("Activity details or timestamp"),
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
