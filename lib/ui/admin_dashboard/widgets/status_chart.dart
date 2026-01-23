import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../data/models/report.dart';

class StatusChart extends StatelessWidget {
  final List<Report> reports;
  const StatusChart({super.key, required this.reports});

  @override
  Widget build(BuildContext context) {
    if (reports.isEmpty) {
      return const Center(
        child: Text(
          'No reports available',
          style: TextStyle(color: Color(0xFF6B7280)),
        ),
      );
    }

    final openCount = reports
        .where((r) => r.status.toLowerCase() == 'open')
        .length;
    final inProgressCount = reports
        .where((r) => r.status.toLowerCase() == 'in_progress')
        .length;
    final closedCount = reports
        .where(
          (r) =>
              r.status.toLowerCase() == 'closed' ||
              r.status.toLowerCase() == 'resolved',
        )
        .length;
    //final total = reports.length;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Pie Chart
          SizedBox(
            width: 180,
            height: 180,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 50,
                startDegreeOffset: -90,
                sections: [
                  if (openCount > 0)
                    PieChartSectionData(
                      color: const Color(0xFFEF4444), // Red for Open
                      value: openCount.toDouble(),
                      title: '',
                      radius: 20,
                    ),
                  if (inProgressCount > 0)
                    PieChartSectionData(
                      color: const Color(0xFFF59E0B), // Amber for In Progress
                      value: inProgressCount.toDouble(),
                      title: '',
                      radius: 20,
                    ),
                  if (closedCount > 0)
                    PieChartSectionData(
                      color: const Color(0xFF10B981), // Green for Closed
                      value: closedCount.toDouble(),
                      title: '',
                      radius: 20,
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Legend
          Wrap(
            spacing: 16,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              _buildLegendItem('Open', const Color(0xFFEF4444), openCount),
              _buildLegendItem(
                'In Progress',
                const Color(0xFFF59E0B),
                inProgressCount,
              ),
              _buildLegendItem('Closed', const Color(0xFF10B981), closedCount),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color, int count) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          '$label ($count)',
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF6B7280),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
