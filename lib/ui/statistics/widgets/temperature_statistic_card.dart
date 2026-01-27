import '../../../data/models/temperature_model.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class TemperatureStatisticCard extends StatelessWidget {
  final double currentTemperature;
  final List<TemperatureModel> readings;
  final DateTime? lastUpdated;

  const TemperatureStatisticCard({
    super.key,
    required this.currentTemperature,
    required this.readings,
    this.lastUpdated,
  });

  @override
  Widget build(BuildContext context) {
    const mainColor = Color(0xFFEA580C); // Orange color
    const borderColor = Color(0xFFFFCCAF); // Light Orange Border

    
    // Generate daily chart data from real readings
    final chartData = _generateDailyData();

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
          mainAxisSize: MainAxisSize.min, // Allow minimum height
          children: [
            // Header Section
             Container(
              padding: const EdgeInsets.all(16), // Reduced padding
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Color(0xFFFFF7ED), width: 1)
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
                        'Temperature',
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
                        currentTemperature.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: mainColor,
                        ),
                      ),
                      const SizedBox(width: 4),
                       const Text(
                        '°C',
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
              padding: const EdgeInsets.all(16), // Reduced padding
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   // Ideal Range Label
                  const Text(
                    'Ideal Range: 55°C - 70°C',
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
                      value: _calculateProgress(currentTemperature),
                      backgroundColor: const Color(0xFFFFEDD5), 
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFC2410C)),
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
                          xValueMapper: (data, _) => data['day'] as String,
                          yValueMapper: (data, _) => data['value'] as double,
                          color: const Color(0xFFC2410C),
                          width: 3,
                          markerSettings: const MarkerSettings(
                            isVisible: true,
                            color: Color(0xFFC2410C),
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

  List<Map<String, dynamic>> _generateDailyData() {
    if (readings.isEmpty) return [];

    // Sort mappings by date to be safe
    final sortedReadings = List<TemperatureModel>.from(readings);
    sortedReadings.sort((a, b) => (a.timestamp ?? DateTime.now()).compareTo(b.timestamp ?? DateTime.now()));

    if (sortedReadings.isEmpty) return [];

    // Calculate start date (midnight of the first reading)
    final firstDate = sortedReadings.first.timestamp ?? DateTime.now();
    final startDate = DateTime(firstDate.year, firstDate.month, firstDate.day);

    return sortedReadings.map((reading) {
      final date = reading.timestamp ?? DateTime.now();
      final currentDate = DateTime(date.year, date.month, date.day);
      final dayDiff = currentDate.difference(startDate).inDays;
      
      return {
        'day': 'Day ${dayDiff + 1}',
        'value': reading.value,
      };
    }).toList();
  }

  double _calculateProgress(double temperature) {
    return (temperature.clamp(0.0, 80.0) / 80.0);
  }
}
