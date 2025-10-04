import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            filter,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        // Time Period (Bar Chart)
        _buildCard(
          title: "Time Period",
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              barTouchData: BarTouchData(enabled: false),
              titlesData: FlTitlesData(
                leftTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: true),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      int index = value.toInt();
                      if (index >= 0 && index < dayLabels.length) {
                        return Text(dayLabels[index],
                            style: const TextStyle(fontSize: 10));
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ),
              gridData: const FlGridData(show: true),
              borderData: FlBorderData(show: false),
              barGroups: List.generate(numberOfDays, (i) {
                return BarChartGroupData(x: i, barRods: [
                  BarChartRodData(
                    toY: (i + 1) * 2.0, // fake data for now
                    color: Colors.green,
                    width: 16,
                  )
                ]);
              }),
            ),
          ),
        ),

        // Humidity (Line Chart)
        _buildCard(
          title: "Humidity",
          child: LineChart(
            LineChartData(
              titlesData: FlTitlesData(
                leftTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: true),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      int index = value.toInt();
                      if (index >= 0 && index < dayLabels.length) {
                        return Text(dayLabels[index],
                            style: const TextStyle(fontSize: 10));
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ),
              gridData: const FlGridData(show: true),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  isCurved: true,
                  spots: List.generate(
                      numberOfDays, (i) => FlSpot(i.toDouble(), 40 + i * 5)),
                  dotData: const FlDotData(show: false),
                  color: Colors.blue,
                ),
                LineChartBarData(
                  isCurved: true,
                  spots: List.generate(
                      numberOfDays, (i) => FlSpot(i.toDouble(), 60 + i * 3)),
                  dotData: const FlDotData(show: false),
                  color: Colors.red,
                ),
              ],
            ),
          ),
        ),

        // Temperature Placeholder
        _buildCard(
          title: "Temperature",
          child: const SizedBox(
            height: 150,
            child: Center(
              child: Text("Temperature chart will be here"),
            ),
          ),
        ),
      ],
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
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          SizedBox(height: 200, child: child),
        ],
      ),
    );
  }
}
