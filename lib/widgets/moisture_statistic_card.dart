import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class MoistureStatisticCard extends StatelessWidget {
  final double currentMoisture;
  final List<double> hourlyReadings;
  final DateTime? lastUpdated;

  const MoistureStatisticCard({
    super.key,
    required this.currentMoisture,
    required this.hourlyReadings,
    this.lastUpdated,
  });

  @override
  Widget build(BuildContext context) {
    if (hourlyReadings.isEmpty) {
      return _buildEmptyCard(context);
    }

    final quality = _getQuality(currentMoisture);
    final color = _getColorForQuality(quality);

    // Precompute chart data once
    final now = DateTime.now();
    final int dataLength = hourlyReadings.length;
    final List<Map<String, Object>> moistureData = List.generate(dataLength, (i) {
      // i=0 → oldest (e.g., 6h ago), i=last → most recent
      final hour = now.subtract(Duration(hours: dataLength - 1 - i)).hour;
      return {
        'x': '${hour.toString().padLeft(2, '0')}:00',
        'y': hourlyReadings[i],
      };
    });

    // Static bounds (ideal range: 20% to 60%)
    final List<Map<String, Object>> upperBound = List.filled(dataLength, {'x': '', 'y': 60.0})
        .asMap()
        .entries
        .map((e) {
      final i = e.key;
      final hour = now.subtract(Duration(hours: dataLength - 1 - i)).hour;
      return {'x': '${hour.toString().padLeft(2, '0')}:00', 'y': 60.0};
    }).toList();

    final List<Map<String, Object>> lowerBound = List.filled(dataLength, {'x': '', 'y': 20.0})
        .asMap()
        .entries
        .map((e) {
      final i = e.key;
      final hour = now.subtract(Duration(hours: dataLength - 1 - i)).hour;
      return {'x': '${hour.toString().padLeft(2, '0')}:00', 'y': 20.0};
    }).toList();

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
                'Moisture',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                '${currentMoisture.toStringAsFixed(0)}%',
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
              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
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

          Text(
            'Ideal Range: 20–60%',
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: _calculateProgress(currentMoisture),
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
          const SizedBox(height: 16),

          Text(
            // ignore: unnecessary_brace_in_string_interps
            'Trend (Last ${dataLength} Hours)',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 90,
            width: double.infinity,
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
                maximum: 100,
                interval: 20,
                majorGridLines: const MajorGridLines(
                  width: 0.5,
                  color: Colors.grey,
                ),
                labelStyle: const TextStyle(fontSize: 9),
              ),
              plotAreaBorderWidth: 0,
              margin: EdgeInsets.zero,
              series: <CartesianSeries>[
                LineSeries<Map<String, Object>, String>(
                  dataSource: moistureData,
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
      child: Center(
        child: Text(
          'No moisture data',
          style: TextStyle(color: Colors.grey[600]),
        ),
      ),
    );
  }

  String _getQuality(double moisture) {
    if (moisture >= 20 && moisture <= 60) return 'Excellent';
    if ((moisture >= 10 && moisture < 20) || (moisture > 60 && moisture <= 75)) return 'Good';
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

  double _calculateProgress(double moisture) {
    return (moisture.clamp(0.0, 100.0) / 100.0);
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year} '
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}