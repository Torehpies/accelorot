import 'package:flutter/material.dart';
import 'activity_list_item.dart';

class AllActivity extends StatelessWidget {
  final String category; // e.g., "All", "Substrate", "Alerts"

  const AllActivity({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    // Placeholder sample logs (replace with dynamic data later)
    final List<String> logs = [
      '$category Log 1',
      '$category Log 2',
      '$category Log 3',
    ];

    return ListView.builder(
      itemCount: logs.length,
      itemBuilder: (context, index) {
        return ActivityListItem(
          title: logs[index],
          subtitle: "Recorded on Oct 16, 2025",
          icon: category == "Alerts"
              ? Icons.warning_amber_rounded
              : Icons.eco_rounded,
          iconColor:
              category == "Alerts" ? Colors.redAccent : Colors.greenAccent,
        );
      },
    );
  }
}
