import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../widgets/oxygen_statistic_card.dart'; // ✅ import your oxygen card

class HistoryPage extends StatelessWidget {
  final String filter;
  final DateTimeRange range;

  const HistoryPage({super.key, required this.filter, required this.range});

  int get numberOfDays =>
      range.end.difference(range.start).inDays + 1; // inclusive days

  List<String> get dayLabels {
    return List.generate(numberOfDays, (index) {
      final date = range.start.add(Duration(days: index));
      return "${date.month}/${date.day}";
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              filter,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),

          // Time Period (Bar Chart)
          _buildCard(
            title: "Time Period",
            child: const SizedBox(
              height: 150,
              child: Center(child: Text("Time Period chart will be here")),
            ),
          ),

          const SizedBox(height: 16),
          OxygenStatisticCard(
            currentOxygen: 21.0,
            hourlyReadings: [20.8, 21.1, 21.2, 20.9, 21.0, 21.1],
            lastUpdated: DateTime.now(),
          ),

          // Temperature Placeholder
          _buildCard(
            title: "Temperature",
            child: const SizedBox(
              height: 150,
              child: Center(child: Text("Temperature chart will be here")),
            ),
          ),
        ],
      ),
    );
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
            color: Colors.green.withValues(alpha: 0.2),
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
          SizedBox(height: 200, child: child),
        ],
      ),
    );
  }
}
