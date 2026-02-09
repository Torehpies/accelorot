import '../../../data/models/moisture_model.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../core/widgets/progress_bar.dart';

class MoistureStatisticCard extends StatelessWidget {
  final double currentMoisture;
  final List<MoistureModel> readings;
  final DateTime? lastUpdated;
  

  const MoistureStatisticCard({
    super.key,
    required this.currentMoisture,
    required this.readings,
    this.lastUpdated,
  });

  

  @override
  Widget build(BuildContext context) {
    const mainColor = Color(0xFF0284C7); // Blue color

    // Generate daily chart data from real readings
    final chartData = _generateDailyData();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
                  bottom: BorderSide(color: Color(0xFFF0F9FF), width: 3),
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
                        'Moisture',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF374151),
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Compost moisture content',
                        style: TextStyle(
                          fontSize: 13,
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
                        currentMoisture.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: mainColor,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        '%',
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
                  // const Text(
                  //   'Ideal Range: 40% - 60%',
                  //   style: TextStyle(
                  //     fontSize: 14,
                  //     fontWeight: FontWeight.w500,
                  //     color: Color(0xFF4B5563),
                  //   ),
                  // ),
                  // const SizedBox(height: 8),

                  // Progress Bar with Range Indicators
                  SimpleRangeProgressBar(
                    currentValue: currentMoisture,
                    minIdeal: 40,
                    maxIdeal: 60,
                    maxScale: 100,
                    unit: '%',
                    primaryColor: const Color(0xFF0369A1),
                    backgroundColor: const Color(0xFFE0F2FE),
                  ),
                  const SizedBox(height: 20),

                  // Chart
                  SizedBox(
                    height: 300,
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
                                    '${value.toStringAsFixed(1)}%\n${timestamp != null ? DateFormat('MMM d, y\nh:mm a').format(timestamp) : ''}',
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
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                              interval: 20,
                              getTitlesWidget: (double value, TitleMeta meta) {
                                return Text(
                                  '${value.toInt()}%',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF9CA3AF),
                                  ),
                                );
                              },
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 30,
                              interval: _getBottomAxisInterval(chartData),
                              getTitlesWidget: (double value, TitleMeta meta) {
                                // Only show labels at the interval
                                if (value % _getBottomAxisInterval(chartData) != 0) {
                                  return const SizedBox.shrink();
                                }
                                return Text(
                                  'Day ${value.toInt() + 1}',
                                  style: const TextStyle(
                                    fontSize: 11,
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
                            isCurved: false, // Sharp angular lines instead of curves
                            color: const Color(0xFF0369A1),
                            barWidth: 2.5,
                            isStrokeCapRound: true,
                            dotData: FlDotData(
                              show: true,
                              checkToShowDot: (spot, barData) {
                                // Only show dots for markers that have non-zero values
                                final downsampledData = _downsampleData(chartData);
                                final index = barData.spots.indexOf(spot);
                                if (index >= 0 && index < downsampledData.length) {
                                  final isMarker = downsampledData[index]['isMarker'] == true;
                                  final hasValue = (downsampledData[index]['value'] as double) > 0;
                                  return isMarker && hasValue;
                                }
                                return false;
                              },
                              getDotPainter: (spot, percent, barData, index) {
                                return FlDotCirclePainter(
                                  radius: 3.5,
                                  color: const Color(0xFF0369A1),
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
                  const Divider(height: 3, thickness: 3, color: Color(0xFFF3F4F6)),
                  const SizedBox(height: 16),
                  
                  // Trend Text
                  // const Text(
                  //   'Trending up by 5.2% this week',
                  //   style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                  // ),
                  // const SizedBox(height: 16),

                  // More Information Section
                  const Text(
                    'More Information:',
                    style: TextStyle(
                      fontSize: 14,
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
      'Optimal for microbial decomposition',
      'Too dry slows breakdown process',
      'Too wet causes anaerobic conditions',
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
                fontSize: 13,
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
    final sortedReadings = List<MoistureModel>.from(readings);
    sortedReadings.sort((a, b) => (a.timestamp ?? DateTime.now()).compareTo(b.timestamp ?? DateTime.now()));

    if (sortedReadings.isEmpty) return [];

    // Calculate start date (midnight of the first reading)
    final firstDate = sortedReadings.first.timestamp ?? DateTime.now();
    final startDate = DateTime(firstDate.year, firstDate.month, firstDate.day);
    
    final List<Map<String, dynamic>> data = [];
    
    // Group by day to get min, max, start, and end values
    final Map<int, List<Map<String, dynamic>>> dayGroups = {};

    for (int i = 0; i < sortedReadings.length; i++) {
        final reading = sortedReadings[i];
        final date = reading.timestamp ?? DateTime.now();
        final diff = date.difference(startDate);
        final double dayValue = diff.inSeconds / (24 * 3600);
        final int dayInt = dayValue.floor();

        if (!dayGroups.containsKey(dayInt)) {
            dayGroups[dayInt] = [];
        }
        
        dayGroups[dayInt]!.add({
            'day': dayValue,
            'value': reading.value,
            'timestamp': date,
        });
    }

    // For each day, keep: start, end, min, and max points
    dayGroups.forEach((day, points) {
      if (points.isEmpty) return;
      
      // Sort points by time within the day
      points.sort((a, b) => (a['day'] as double).compareTo(b['day'] as double));
      
      final start = points.first;
      final end = points.last;
      
      // Find min and max values
      var minPoint = points.first;
      var maxPoint = points.first;
      
      for (var point in points) {
        if ((point['value'] as double) < (minPoint['value'] as double)) {
          minPoint = point;
        }
        if ((point['value'] as double) > (maxPoint['value'] as double)) {
          maxPoint = point;
        }
      }
      
      // Add unique points (start is always a marker)
      final uniquePoints = <Map<String, dynamic>>{};
      
      // Add start point (marked)
      uniquePoints.add({...start, 'isMarker': true});
      
      // Add min if different from start/end
      if (minPoint != start && minPoint != end) {
        uniquePoints.add({...minPoint, 'isMarker': false});
      }
      
      // Add max if different from start/end
      if (maxPoint != start && maxPoint != end) {
        uniquePoints.add({...maxPoint, 'isMarker': false});
      }
      
      // Add end if different from start
      if (end != start) {
        uniquePoints.add({...end, 'isMarker': false});
      }
      
      // Convert set back to list and sort by day value
      final dayData = uniquePoints.toList();
      dayData.sort((a, b) => (a['day'] as double).compareTo(b['day'] as double));
      data.addAll(dayData);
    });

    return data;
  }

  // Smart downsampling that preserves important points
  List<Map<String, dynamic>> _downsampleData(List<Map<String, dynamic>> data) {
    // Already optimized in _generateDailyData, so just return
    return data;
  }

  // Calculate appropriate interval for bottom axis labels based on number of days
  double _getBottomAxisInterval(List<Map<String, dynamic>> data) {
    if (data.isEmpty) return 1.0;
    
    final maxDay = data.map((d) => (d['day'] as double).floor()).reduce((a, b) => a > b ? a : b);
    final totalDays = maxDay + 1;
    
    // Adjust interval based on total days to prevent crowding
    if (totalDays <= 7) {
      return 1.0; // Show every day
    } else if (totalDays <= 14) {
      return 2.0; // Show every 2 days
    } else if (totalDays <= 30) {
      return 3.0; // Show every 3 days
    } else {
      return 5.0; // Show every 5 days
    }
  }

}

class RangeIndicatorPainter extends CustomPainter {
  final double minPercent;
  final double maxPercent;

  RangeIndicatorPainter({
    required this.minPercent,
    required this.maxPercent,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF22C55E)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final minX = (minPercent / 100) * size.width;
    final maxX = (maxPercent / 100) * size.width;

    // Draw vertical lines at min and max
    canvas.drawLine(
      Offset(minX, 0),
      Offset(minX, size.height),
      paint,
    );
    canvas.drawLine(
      Offset(maxX, 0),
      Offset(maxX, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(RangeIndicatorPainter oldDelegate) {
    return oldDelegate.minPercent != minPercent || oldDelegate.maxPercent != maxPercent;
  }
}