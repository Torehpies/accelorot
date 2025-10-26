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
    final start = DateTime(range.start.year, range.start.month, range.start.day);
    final end = DateTime(range.end.year, range.end.month, range.end.day);
    final days = end.difference(start).inDays + 1;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔹 Header
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "(${_formatDate(start)} - ${_formatDate(end)})",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),

          // 🔹 Keep summary card
          //_buildCard(
          //  title: "Time Period Summary",
          //  child: Center(
          //    child: Text(
          //      "Showing $days days of data",
          //      style: const TextStyle(fontSize: 14, color: Colors.grey),
          //    ),
          //  ),
          //),

          const SizedBox(height: 16),

          // 🔹 Directly show Oxygen History View (no extra box)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: OxygenStatsHistoryView(
              machineId: "01",
              range: DateTimeRange(start: start, end: end),
            ),
          ),

          const SizedBox(height: 16),

          // 🔹 Directly show Temperature History View
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: TemperatureStatsHistoryView(
              machineId: "01",
              range: DateTimeRange(start: start, end: end),
            ),
          ),

          const SizedBox(height: 16),

          // 🔹 Directly show Moisture History View
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: MoistureStatsHistoryView(
              machineId: "01",
              range: DateTimeRange(start: start, end: end),
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

  Widget _buildCard({required String title, required Widget child}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withAlpha(50),
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}
