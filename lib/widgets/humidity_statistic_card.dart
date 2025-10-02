// lib/components/humidity_statistic_card.dart
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class HumidityStatisticCard extends StatelessWidget {
  final double currentHumidity;
  final List<double> hourlyReadings;
  final DateTime? lastUpdated;

  const HumidityStatisticCard({
    super.key,
    required this.currentHumidity,
    required this.hourlyReadings,
    this.lastUpdated,
  });

  @override
  Widget build(BuildContext context) {
    if (hourlyReadings.isEmpty) {
      return Container(
        width: double.infinity, // 👈 Ensure full width even when empty
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.green.shade100),
          boxShadow: [
            BoxShadow(
              color: Colors.green.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(18),
        child: Center(
          child: Text(
            'No humidity data',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ),
      );
    }

    final quality = _getQuality(currentHumidity);
    final color = _getColorForQuality(quality);

    return Container(
      width: double.infinity, // 👈 THIS IS THE CRITICAL FIX - ensures full width
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Humidity',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text(
                '${currentHumidity.toStringAsFixed(0)}%',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          if (lastUpdated != null)
            Text(
              'Last updated: ${_formatDate(lastUpdated!)}',
              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
            ),
          const SizedBox(height: 12),

          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'Quality: $quality',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Text(
            'Ideal Range: 40–65%',
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: _calculateProgress(currentHumidity),
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
          const SizedBox(height: 16),

          Text(
            'Trend (Last 6 Hours)',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 90,
            width: double.infinity, // 👈 Chart fills full card width
            child: SfCartesianChart(
              primaryXAxis: CategoryAxis(
                labelStyle: const TextStyle(fontSize: 9),
                majorGridLines: const MajorGridLines(width: 0.5, color: Colors.grey),
                interval: 1,
              ),
              primaryYAxis: NumericAxis(
                minimum: 25,
                maximum: 105,
                interval: 20,
                majorGridLines: const MajorGridLines(width: 0.5, color: Colors.grey),
                labelStyle: const TextStyle(fontSize: 9),
              ),
              plotAreaBorderWidth: 0,
              margin: const EdgeInsets.all(0),
              series: <CartesianSeries>[
                LineSeries<Map<String, Object>, String>(
                  dataSource: List<Map<String, Object>>.from(
                    List.generate(hourlyReadings.length, (i) {
                      final hour = DateTime.now().add(Duration(hours: -6 + i)).hour;
                      return <String, Object>{
                        'x': '$hour:00',
                        'y': hourlyReadings[i],
                      };
                    }),
                  ),
                  xValueMapper: (Map<String, Object> data, _) => data['x'] as String,
                  yValueMapper: (Map<String, Object> data, _) => data['y'] as double,
                  color: Colors.blue,
                  width: 2,
                  markerSettings: const MarkerSettings(isVisible: true),
                ),
                LineSeries<Map<String, Object>, String>(
                  dataSource: List<Map<String, Object>>.from(
                    List.generate(hourlyReadings.length, (i) {
                      final hour = DateTime.now().add(Duration(hours: -6 + i)).hour;
                      return <String, Object>{
                        'x': '$hour:00',
                        'y': 65.0,
                      };
                    }),
                  ),
                  xValueMapper: (Map<String, Object> data, _) => data['x'] as String,
                  yValueMapper: (Map<String, Object> data, _) => data['y'] as double,
                  color: Colors.red,
                  dashArray: const [5, 5],
                  width: 1,
                ),
                LineSeries<Map<String, Object>, String>(
                  dataSource: List<Map<String, Object>>.from(
                    List.generate(hourlyReadings.length, (i) {
                      final hour = DateTime.now().add(Duration(hours: -6 + i)).hour;
                      return <String, Object>{
                        'x': '$hour:00',
                        'y': 40.0,
                      };
                    }),
                  ),
                  xValueMapper: (Map<String, Object> data, _) => data['x'] as String,
                  yValueMapper: (Map<String, Object> data, _) => data['y'] as double,
                  color: Colors.red,
                  dashArray: const [5, 5],
                  width: 1,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getQuality(double humidity) {
    if (humidity >= 40 && humidity <= 65) return 'Excellent';
    if ((humidity >= 30 && humidity < 40) || (humidity > 65 && humidity <= 75)) return 'Good';
    return 'Poor';
  }

  Color _getColorForQuality(String quality) {
    switch (quality) {
      case 'Excellent':
        return Colors.green;
      case 'Good':
        return Colors.orange;
      default:
        return Colors.red;
    }
  }

  double _calculateProgress(double humidity) {
    // Normalize to 0-1 range properly
    if (humidity <= 0) return 0.0;
    if (humidity >= 100) return 1.0;
    return humidity / 100;
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year} '
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}