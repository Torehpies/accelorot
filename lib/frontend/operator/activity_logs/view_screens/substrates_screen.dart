import 'package:flutter/material.dart';

class SubstratesScreen extends StatefulWidget {
  const SubstratesScreen({super.key});

  @override
  State<SubstratesScreen> createState() => _SubstratesScreenState();
}

class _SubstratesScreenState extends State<SubstratesScreen> {
  String selectedFilter = 'All';
  final filters = const ['All', 'Greens', 'Browns', 'Compost'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Substrate Logs"),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 🔹 Filter chips (top section)
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

            // 🔹 Scrollable list (filtered items)
            Expanded(
              child: ListView.builder(
                itemCount: 6,
                itemBuilder: (context, index) {
                  return Card(
                    elevation: 3,
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: Icon(
                        Icons.grass,
                        color: selectedFilter == 'Browns'
                            ? Colors.brown
                            : selectedFilter == 'Compost'
                                ? Colors.green
                                : Colors.teal,
                      ),
                      title: Text("Substrate #${index + 1}"),
                      subtitle: Text(
                        selectedFilter == 'All'
                            ? "Mixed Substrate"
                            : "$selectedFilter Type",
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
