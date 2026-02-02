import '../../../data/models/oxygen_model.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class OxygenStatisticCard extends StatelessWidget {
  final double currentOxygen;
  final List<OxygenModel> readings;
  final DateTime? lastUpdated;

  const OxygenStatisticCard({
    super.key,
    required this.currentOxygen,
    required this.readings,
    this.lastUpdated,
  });

  @override
  Widget build(BuildContext context) {
    const mainColor = Color(0xFF7C3AED); // Purple color
    const borderColor = Color(0xFFDDD6FE); // Light Purple Border

    // Generate daily chart data from real readings
    final chartData = _generateDailyData();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 2), // Full colored border
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
             // Header Section
             Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Color(0xFFFAF5FF), width: 1),
                ),
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
                        currentOxygen.toStringAsFixed(0),
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
                      backgroundColor: const Color(
                        0xFFF3E8FF,
                      ), // Very light purple
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFF6D28D9),
                      ), // Darker Purple
                      minHeight: 12,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Chart
                  SizedBox(
                    height: 120,
                    child: LineChart(
                      LineChartData(
                        lineTouchData: LineTouchData(
                          enabled: true,
                          touchTooltipData: LineTouchTooltipData(
                            getTooltipColor: (touchedSpot) => Colors.white,
                            getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                              return touchedBarSpots.map((barSpot) {
                                final dataIndex = barSpot.spotIndex;
                                final downsampledData = _downsampleData(chartData);
                                if (dataIndex < downsampledData.length) {
                                  final data = downsampledData[dataIndex];
                                  final timestamp = data['timestamp'] as DateTime?;
                                  final value = barSpot.y;
                                  
                                  return LineTooltipItem(
                                    '${value.toStringAsFixed(0)} ppm\n${timestamp != null ? DateFormat('MMM d, y\nh:mm a').format(timestamp) : ''}',
                                    const TextStyle(
                                      color: Color(0xFF1F2937),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  );
                                }
                                return null;
                              }).toList();
                            },
                            tooltipBorder: const BorderSide(color: Color(0xFFE5E7EB), width: 1),
                            tooltipPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                        ),
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          drawHorizontalLine: true,
                          horizontalInterval: null,
                          getDrawingHorizontalLine: (value) {
                            return FlLine(
                              color: const Color(0xFFF3F4F6),
                              strokeWidth: 1,
                            );
                          },
                        ),
                        titlesData: FlTitlesData(
                          show: true,
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          leftTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 30,
                              interval: 1,
                              getTitlesWidget: (double value, TitleMeta meta) {
                                return Text(
                                  'Day ${value.toInt() + 1}',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Color(0xFF9CA3AF),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        lineBarsData: [
                          LineChartBarData(
                            spots: _downsampleData(chartData).map((d) => FlSpot(d['day'] as double, d['value'] as double)).toList(),
                            isCurved: true,
                            color: const Color(0xFF6D28D9),
                            barWidth: 2.5,
                            isStrokeCapRound: true,
                            dotData: FlDotData(
                              show: true,
                              checkToShowDot: (spot, barData) {
                                final downsampledData = _downsampleData(chartData);
                                final index = barData.spots.indexOf(spot);
                                if (index >= 0 && index < downsampledData.length) {
                                  return downsampledData[index]['isMarker'] == true;
                                }
                                return false;
                              },
                              getDotPainter: (spot, percent, barData, index) {
                                return FlDotCirclePainter(
                                  radius: 3.5,
                                  color: const Color(0xFF6D28D9),
                                  strokeWidth: 2,
                                  strokeColor: Colors.white,
                                );
                              },
                            ),
                            belowBarData: BarAreaData(show: false),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Divider
                  const Divider(height: 1, thickness: 1, color: Color(0xFFF3F4F6)),
                  const SizedBox(height: 16),
                  
                  // Trend Text
                  const Text(
                    'Trending up by 5.2% this week',
                    style: TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
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
    final sortedReadings = List<OxygenModel>.from(readings);
    sortedReadings.sort((a, b) => (a.timestamp ?? DateTime.now()).compareTo(b.timestamp ?? DateTime.now()));

    if (sortedReadings.isEmpty) return [];

    // Calculate start date (midnight of the first reading)
    final firstDate = sortedReadings.first.timestamp ?? DateTime.now();
    final startDate = DateTime(firstDate.year, firstDate.month, firstDate.day);
    
    final List<Map<String, dynamic>> data = [];
    
    // Group by day to identify start/end for markers
    final Map<int, List<int>> dayIndices = {};

    for (int i = 0; i < sortedReadings.length; i++) {
        final reading = sortedReadings[i];
        final date = reading.timestamp ?? DateTime.now();
        // Calculate continuous day value (e.g., 0.5 for noon on Day 1)
        final diff = date.difference(startDate);
        // Use exact fractional days for X axis
        final double dayValue = diff.inSeconds / (24 * 3600);
        final int dayInt = dayValue.floor();

        if (!dayIndices.containsKey(dayInt)) {
            dayIndices[dayInt] = [];
        }
        dayIndices[dayInt]!.add(i);

        data.add({
            'day': dayValue,
            'value': reading.value,
            'isMarker': false,
            'timestamp': date,
        });
    }

    // Mark only the start of each day
  dayIndices.forEach((day, indices) {
      if (indices.isNotEmpty) {
          data[indices.first]['isMarker'] = true; // Start of day only
      }
  });

    return data;
  }

  // Downsample data to reduce visual clutter when there are too many points
  List<Map<String, dynamic>> _downsampleData(List<Map<String, dynamic>> data) {
    if (data.length <= 50) return data;
    
    final int step = (data.length / 50).ceil();
    final List<Map<String, dynamic>> downsampled = [];
    
    for (int i = 0; i < data.length; i++) {
      if (data[i]['isMarker'] == true || i % step == 0) {
        downsampled.add(data[i]);
      }
    }
    
    return downsampled;
  }

  double _calculateProgress(double oxygen) {
    return (oxygen.clamp(0.0, 5000.0) / 5000.0);
  }
}
