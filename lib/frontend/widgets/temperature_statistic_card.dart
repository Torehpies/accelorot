import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class TemperatureStatisticCard extends StatelessWidget {
  final double currentTemperature;
  final List<double> hourlyReadings;
  final DateTime? lastUpdated;

  const TemperatureStatisticCard({
    super.key,
    required this.currentTemperature,
    required this.hourlyReadings,
    this.lastUpdated,
  });

  @override
  Widget build(BuildContext context) {
    if (hourlyReadings.isEmpty) {
      return _buildEmptyCard(context);
    }

    final quality = _getQuality(currentTemperature);
    final color = _getColorForQuality(quality);
    final now = DateTime.now();
    final dataLength = hourlyReadings.length;

    // Generate X-axis labels and data once
    final temperatureData = <Map<String, Object>>[];
    final upperBound = <Map<String, Object>>[];
    final lowerBound = <Map<String, Object>>[];

    for (int i = 0; i < dataLength; i++) {
      final hour = now.subtract(Duration(hours: dataLength - 1 - i)).hour;
      final timeLabel = '${hour.toString().padLeft(2, '0')}:00';
      temperatureData.add({'x': timeLabel, 'y': hourlyReadings[i]});
      upperBound.add({'x': timeLabel, 'y': 24.0});
      lowerBound.add({'x': timeLabel, 'y': 18.0});
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withValues(alpha: 0.1),
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
                'Temperature',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                '${currentTemperature.toStringAsFixed(1)}°C',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          if (lastUpdated != null) ...[
            const SizedBox(height: 4),
            Text(
              'Last updated: ${_formatDate(lastUpdated!)}',
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
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
          const Text(
            'Ideal Range: 18–24°C',
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: _calculateProgress(currentTemperature),
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
          const SizedBox(height: 16),
          const Text(
            'Trend (Last N Hours)',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 90,
            child: SfCartesianChart(
              primaryXAxis: CategoryAxis(
                labelStyle: const TextStyle(fontSize: 9),
                majorGridLines: const MajorGridLines(
                  width: 0.5,
                  color: Colors.grey,
                ),
                interval: 1,
              ),
              primaryYAxis: NumericAxis(
                minimum: 0,
                maximum: 40,
                interval: 10,
                majorGridLines: const MajorGridLines(
                  width: 0.5,
                  color: Colors.grey,
                ),
                labelStyle: const TextStyle(fontSize: 9),
              ),
              plotAreaBorderWidth: 0,
              margin: EdgeInsets.zero,
              series: [
                LineSeries<Map<String, Object>, String>(
                  dataSource: temperatureData,
                  xValueMapper: (data, _) => data['x'] as String,
                  yValueMapper: (data, _) => data['y'] as double,
                  color: Colors.blue,
                  width: 2,
                  markerSettings: const MarkerSettings(isVisible: true),
                ),
                LineSeries<Map<String, Object>, String>(
                  dataSource: upperBound,
                  xValueMapper: (data, _) => data['x'] as String,
                  yValueMapper: (data, _) => data['y'] as double,
                  color: Colors.red,
                  dashArray: const [5, 5],
                  width: 1,
                ),
                LineSeries<Map<String, Object>, String>(
                  dataSource: lowerBound,
                  xValueMapper: (data, _) => data['x'] as String,
                  yValueMapper: (data, _) => data['y'] as double,
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

  Widget _buildEmptyCard(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: const Center(
        child: Text(
          'No temperature data',
          style: TextStyle(color: Colors.grey),
        ),
      ),
    );
  }

  String _getQuality(double temperature) {
    if (temperature >= 18 && temperature <= 24) return 'Excellent';
    if ((temperature >= 15 && temperature < 18) ||
        (temperature > 24 && temperature <= 27)) {
      return 'Good';
    }
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

  double _calculateProgress(double temperature) {
    return (temperature.clamp(0.0, 40.0) / 40.0);
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year} '
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
