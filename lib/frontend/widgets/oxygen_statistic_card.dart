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
    if (hourlyReadings.isEmpty) {
      return _buildEmptyCard(context);
    }

    final quality = _getQuality(currentOxygen);
    final color = _getColorForQuality(quality);

    final now = DateTime.now();
    final int dataLength = hourlyReadings.length;
    final List<Map<String, Object>> oxygenData = List.generate(dataLength, (i) {
      final hour = now.subtract(Duration(hours: dataLength - 1 - i)).hour;
      return {
        'x': '${hour.toString().padLeft(2, '0')}:00',
        'y': hourlyReadings[i],
      };
    });

    // Ideal oxygen range: 19.5% – 23.5%
    final List<Map<String, Object>> upperBound =
        List.generate(dataLength, (i) {
      final hour = now.subtract(Duration(hours: dataLength - 1 - i)).hour;
      return {'x': '${hour.toString().padLeft(2, '0')}:00', 'y': 23.5};
    });

    final List<Map<String, Object>> lowerBound =
        List.generate(dataLength, (i) {
      final hour = now.subtract(Duration(hours: dataLength - 1 - i)).hour;
      return {'x': '${hour.toString().padLeft(2, '0')}:00', 'y': 19.5};
    });

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header and current oxygen level
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Oxygen Level',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                '${currentOxygen.toStringAsFixed(1)}%',
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

          // Quality indicator
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
            'Ideal Range: 19.5–23.5%',
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: _calculateProgress(currentOxygen),
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
          const SizedBox(height: 16),

          Text(
            'Trend (Last $dataLength Hours)',
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
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
                minimum: 15,
                maximum: 25,
                interval: 2,
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
                  dataSource: oxygenData,
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
        border: Border.all(color: Colors.green.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withValues(alpha:0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Center(
        child: Text(
          'No oxygen data',
          style: TextStyle(color: Colors.grey[600]),
        ),
      ),
    );
  }

  String _getQuality(double oxygen) {
    if (oxygen >= 19.5 && oxygen <= 23.5) return 'Excellent';
    if ((oxygen >= 18.0 && oxygen < 19.5) || (oxygen > 23.5 && oxygen <= 24.0)) {
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

  double _calculateProgress(double oxygen) {
    return (oxygen.clamp(0.0, 25.0) / 25.0);
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year} '
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
