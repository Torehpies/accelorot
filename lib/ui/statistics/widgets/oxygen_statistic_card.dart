import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class OxygenStatisticCard extends StatelessWidget {
  final double currentOxygen;
  final List<double> hourlyReadings;
  final DateTime? lastUpdated;

  const OxygenStatisticCard({
    super.key,
    required this.currentOxygen,
    required this.hourlyReadings,
    this.lastUpdated,
  });

  @override
  Widget build(BuildContext context) {
    const mainColor = Color(0xFF7C3AED); // Purple color
    const borderColor = Color(0xFFDDD6FE); // Light Purple Border

    // Generate monthly chart data (sample for now)
    final chartData = _generateMonthlyData();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 2), // Full colored border
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
             // Header Section
             Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Color(0xFFFAF5FF), width: 1)
                )
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                       const Text(
                        'Air Quality',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF374151),
                        ),
                      ),
                      const SizedBox(height: 2),
                       const Text(
                        'sample text description...',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF9CA3AF),
                        ),
                      ),
                    ],
                  ),
                   Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '${currentOxygen.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: mainColor,
                        ),
                      ),
                      const SizedBox(width: 4),
                       const Text(
                        'ppm',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: mainColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Ideal Range Label
                  const Text(
                    'Ideal Range: 65 ppm - 70 ppm',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF4B5563),
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Progress Bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: _calculateProgress(currentOxygen),
                      backgroundColor: const Color(0xFFF3E8FF), // Very light purple
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF6D28D9)), // Darker Purple
                      minHeight: 12,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Chart
                  SizedBox(
                    height: 100, // Reduced height
                    child: SfCartesianChart(
                      plotAreaBorderWidth: 0,
                      margin: EdgeInsets.zero,
                      primaryXAxis: CategoryAxis(
                        labelStyle: const TextStyle(fontSize: 10, color: Color(0xFF9CA3AF)),
                        majorGridLines: const MajorGridLines(width: 0),
                        axisLine: const AxisLine(width: 0),
                      ),
                      primaryYAxis: NumericAxis(
                        isVisible: false,
                        majorGridLines: const MajorGridLines(width: 0),
                      ),
                      series: <CartesianSeries>[
                        SplineSeries<Map<String, dynamic>, String>(
                          dataSource: chartData,
                          xValueMapper: (data, _) => data['month'] as String,
                          yValueMapper: (data, _) => data['value'] as double,
                          color: const Color(0xFF6D28D9), // Darker purple line
                          width: 3,
                          markerSettings: const MarkerSettings(
                            isVisible: true,
                            color: Color(0xFF6D28D9),
                            borderColor: Colors.white,
                            borderWidth: 2,
                            height: 8,
                            width: 8,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Trend Text
                  const Text(
                    'Trending up by 5.2% this week',
                    style: TextStyle(
                      fontSize: 11,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // More Information Section
                  const Text(
                    'More Information:',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ..._buildMoreInfo(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildMoreInfo() {
    final items = [
      'sample text here',
      'sample text here',
      'sample text here',
      'sample text here',
    ];
    
    return items.map((item) => Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
           Container(
            width: 4,
            height: 4,
            decoration: const BoxDecoration(
              color: Color(0xFF9CA3AF),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              item,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF6B7280),
              ),
            ),
          ),
        ],
      ),
    )).toList();
  }

  List<Map<String, dynamic>> _generateMonthlyData() {
    return [
      {'month': 'Jan', 'value': 40.0},
      {'month': 'Feb', 'value': 75.0},
      {'month': 'Mar', 'value': 55.0},
      {'month': 'Apr', 'value': 25.0},
      {'month': 'May', 'value': 60.0},
      {'month': 'Jun', 'value': 62.0},
    ];
  }

  double _calculateProgress(double oxygen) {
    return (oxygen.clamp(0.0, 5000.0) / 5000.0);
  }
}
