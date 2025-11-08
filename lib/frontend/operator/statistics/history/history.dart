import 'package:flutter/material.dart';
import '../history/view_screens/oxygen_stats_history_view.dart';
import '../history/view_screens/temperature_stats_history_view.dart';
import '../history/view_screens/moisture_stats_history_view.dart';

class HistoryPage extends StatelessWidget {
  final String filter;
  final DateTimeRange range;

  const HistoryPage({super.key, required this.filter, required this.range});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔹 Header
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "(${_formatDate(range.start)} - ${_formatDate(range.end)})",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),

          const SizedBox(height: 16),

          // 🔹 Directly show Oxygen History View (no extra box)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: OxygenStatsHistoryView(
              machineId: "01",
              range: range,
            ),
          ),

          const SizedBox(height: 16),

          // 🔹 Directly show Temperature History View
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: TemperatureStatsHistoryView(
              machineId: "01",
              range: range,
            ),
          ),

          const SizedBox(height: 16),

          // 🔹 Directly show Moisture History View
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: MoistureStatsHistoryView(
              machineId: "01",
              range: range,
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.month}/${date.day}/${date.year}";
  }
}