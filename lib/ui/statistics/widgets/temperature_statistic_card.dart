import '../../../data/models/temperature_model.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

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
                                    '${value.toStringAsFixed(1)}°C\n${timestamp != null ? DateFormat('MMM d, y\nh:mm a').format(timestamp) : ''}',
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
                          horizontalInterval: null, // Let us control the lines
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
                            color: const Color(0xFFC2410C),
                            barWidth: 2.5, // Balanced thickness for visibility
                            isStrokeCapRound: true,
                            dotData: FlDotData(
                              show: true,
                              checkToShowDot: (spot, barData) {
                                // Only show dots for markers
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
                                  color: const Color(0xFFC2410C),
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
            'isMarker': false, // Default no marker
            'timestamp': date, // Store timestamp for tooltip
        });
    }

    // Mark start and end of each day
    dayIndices.forEach((day, indices) {
        if (indices.isNotEmpty) {
            data[indices.first]['isMarker'] = true; // Start of day
            data[indices.last]['isMarker'] = true;  // End of day
        }
    });

    return data;
  }

  // Downsample data to reduce visual clutter when there are too many points
  List<Map<String, dynamic>> _downsampleData(List<Map<String, dynamic>> data) {
    if (data.length <= 50) return data; // No need to downsample
    
    // Keep every Nth point, but always keep markers (start/end of days)
    final int step = (data.length / 50).ceil();
    final List<Map<String, dynamic>> downsampled = [];
    
    for (int i = 0; i < data.length; i++) {
      // Keep if it's a marker OR if it's on the step interval
      if (data[i]['isMarker'] == true || i % step == 0) {
        downsampled.add(data[i]);
      }
    }
    
    return downsampled;
  }

  double _calculateProgress(double temperature) {
    return (temperature.clamp(0.0, 80.0) / 80.0);
  }
}
