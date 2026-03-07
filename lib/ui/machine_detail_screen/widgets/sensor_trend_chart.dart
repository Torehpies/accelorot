import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math' as math;
import 'package:intl/intl.dart';

class SensorTrendChart extends StatelessWidget {
  final List<Map<String, dynamic>> chartData;
  final Color mainColor;
  final String unit;
  final double maxY;
  final bool isPPM; // Adjusts decimal places and specific formatting

  const SensorTrendChart({
    super.key,
    required this.chartData,
    required this.mainColor,
    required this.unit,
    required this.maxY,
    this.isPPM = false,
  });

  @override
  Widget build(BuildContext context) {
    if (chartData.isEmpty) {
      return const Center(child: Text('No historical data available for this batch.'));
    }

    double peakVal = 0;
    double minVal = 0;
    
    if (chartData.isNotEmpty) {
      final nonZeroValues = chartData
          .map((d) => d['value'] as double)
          .where((v) => v > 0)
          .toList();
          
      peakVal = chartData.map((d) => d['value'] as double).reduce(math.max);
      minVal = nonZeroValues.isNotEmpty ? nonZeroValues.reduce(math.min) : 0;
    }
    
    double midVal = (minVal + peakVal) / 2;
    
    Set<double> targetYValues = {0.0};
    if (minVal > 0) targetYValues.add(minVal);
    if (peakVal > minVal) {
      if (midVal > minVal && midVal < peakVal) targetYValues.add(midVal);
      targetYValues.add(peakVal);
    }

    return LineChart(
      LineChartData(
        clipData: const FlClipData.none(),
        extraLinesData: ExtraLinesData(
          extraLinesOnTop: false,
          horizontalLines: targetYValues.map((yVal) {
            return HorizontalLine(
              y: yVal,
              color: const Color(0xFFF3F4F6),
              strokeWidth: 1.5,
              label: HorizontalLineLabel(
                show: true,
                alignment: Alignment.centerLeft,
                // Negative padding to perfectly align within the leftTitles reserved space
                padding: EdgeInsets.only(left: isPPM ? -55 : -40),
                labelResolver: (line) {
                  final valStr = isPPM ? line.y.toStringAsFixed(0) : line.y.toStringAsFixed(1);
                  return '$valStr$unit';
                },
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF9CA3AF),
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          }).toList(),
        ),
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (touchedSpot) => Colors.white,
            getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
              return touchedBarSpots.map((barSpot) {
                final dataIndex = barSpot.spotIndex;
                if (dataIndex < chartData.length) {
                  final data = chartData[dataIndex];
                  final timestamp = data['timestamp'] as DateTime?;
                  final value = barSpot.y;
                  final formattedValue = isPPM ? value.toStringAsFixed(0) : value.toStringAsFixed(1);

                  return LineTooltipItem(
                    '$formattedValue$unit\n${timestamp != null ? DateFormat('MMM d, y\nh:mm a').format(timestamp) : ''}',
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
          show: false, // We use extraLinesData for grids instead
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
              reservedSize: isPPM ? 60 : 45,
              getTitlesWidget: (double value, TitleMeta meta) {
                return const SizedBox.shrink(); // Space is reserved, but handled by HorizontalLineLabel
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: _getBottomAxisInterval(chartData),
              getTitlesWidget: (double value, TitleMeta meta) {
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
        minX: 0,
        maxX: _getMaxDay(chartData) + 0.1,
        minY: 0,
        maxY: peakVal == 0 ? 10 : peakVal * 1.1, // Leave 10% headroom
        lineBarsData: [
          LineChartBarData(
            spots: chartData.map((d) => FlSpot(d['day'] as double, d['value'] as double)).toList(),
            isCurved: false,
            color: mainColor,
            barWidth: 2.5,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              checkToShowDot: (spot, barData) {
                final index = barData.spots.indexOf(spot);
                if (index >= 0 && index < chartData.length) {
                  final isMarker = chartData[index]['isMarker'] == true;
                  final hasValue = (chartData[index]['value'] as double) > 0;
                  return isMarker && hasValue;
                }
                return false;
              },
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 3.5,
                  color: mainColor,
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(show: false),
          ),
        ],
      ),
    );
  }

  double _getMaxDay(List<Map<String, dynamic>> data) {
    if (data.isEmpty) return 6;

    final maxDay = data
        .map((d) => d['day'] as double)
        .reduce((a, b) => a > b ? a : b);

    return maxDay.ceilToDouble();
  }

  double _getBottomAxisInterval(List<Map<String, dynamic>> data) {
    if (data.isEmpty) return 1.0;
    
    final maxDay = data.map((d) => (d['day'] as double).floor()).reduce((a, b) => a > b ? a : b);
    final totalDays = maxDay + 1;
    
    if (totalDays <= 7) {
      return 1.0;
    } else if (totalDays <= 14) {
      return 2.0;
    } else if (totalDays <= 30) {
      return 3.0;
    } else {
      return 5.0;
    }
  }
}
