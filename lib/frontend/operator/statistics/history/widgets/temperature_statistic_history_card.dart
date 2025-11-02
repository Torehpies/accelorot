import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';

class TemperatureStatisticHistoryCard extends StatelessWidget {
  final double currentTemperature;
  final List<double> dailyReadings;
  final DateTime? lastUpdated;
  final List<String>? labels; 

  const TemperatureStatisticHistoryCard({
    super.key,
    required this.currentTemperature,
    required this.dailyReadings,
    this.lastUpdated,
    this.labels,
  });

  @override
  Widget build(BuildContext context) {
    if (dailyReadings.isEmpty) {
      return _buildEmptyCard(context);
    }

    final quality = _getQuality(currentTemperature);
    final color = _getColorForQuality(quality);
    final dataLength = dailyReadings.length;

    final List<_ChartPoint> temperatureData = [];
    final List<_ChartPoint> upperBound = [];
    final List<_ChartPoint> lowerBound = [];

    for (int i = 0; i < dataLength; i++) {
      final label = (labels != null && i < labels!.length) 
          ? _formatLabel(labels![i]) 
          : 'Day ${i + 1}';
      
      temperatureData.add(_ChartPoint(label, dailyReadings[i]));
      upperBound.add(_ChartPoint(label, 65.0));
      lowerBound.add(_ChartPoint(label, 55.0));
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withValues(alpha: 0.1),
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
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
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
            'Ideal Range: 55–65°C',
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
          Text(
            'Trend ($dataLength Days)',
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 120,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final calculatedWidth = dataLength * 50.0;
                final chartWidth = calculatedWidth > constraints.maxWidth 
                    ? calculatedWidth 
                    : constraints.maxWidth;
                
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: chartWidth,
                    child: SfCartesianChart(
                      primaryXAxis: CategoryAxis(
                        labelStyle: const TextStyle(fontSize: 9),
                        majorGridLines:
                            const MajorGridLines(width: 0.5, color: Colors.grey),
                        interval: 1,
                      ),
                      primaryYAxis: NumericAxis(
                        minimum: 0,
                        maximum: 80,
                        interval: 10,
                        majorGridLines:
                            const MajorGridLines(width: 0.5, color: Colors.grey),
                        labelStyle: const TextStyle(fontSize: 9),
                      ),
                      plotAreaBorderWidth: 0,
                      margin: EdgeInsets.zero,
                      series: [
                        LineSeries<_ChartPoint, String>(
                          dataSource: temperatureData,
                          xValueMapper: (data, _) => data.x,
                          yValueMapper: (data, _) => data.y,
                          color: Colors.orange,
                          width: 2,
                          markerSettings: const MarkerSettings(isVisible: true),
                        ),
                        LineSeries<_ChartPoint, String>(
                          dataSource: upperBound,
                          xValueMapper: (data, _) => data.x,
                          yValueMapper: (data, _) => data.y,
                          color: Colors.red,
                          dashArray: const [5, 5],
                          width: 1,
                        ),
                        LineSeries<_ChartPoint, String>(
                          dataSource: lowerBound,
                          xValueMapper: (data, _) => data.x,
                          yValueMapper: (data, _) => data.y,
                          color: Colors.red,
                          dashArray: const [5, 5],
                          width: 1,
                        ),
                      ],
                    ),
                  ),
                );
              },
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
        border: Border.all(color: Colors.orange.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: const Center(
        child: Text(
          'No temperature data available',
          style: TextStyle(color: Colors.grey),
        ),
      ),
    );
  }

  String _getQuality(double temperature) {
    if (temperature >= 55 && temperature <= 65) return 'Optimal';
    if ((temperature >= 40 && temperature < 55) ||
        (temperature > 65 && temperature <= 70)) {
      return 'Moderate';
    }
    return 'Poor';
  }

  Color _getColorForQuality(String quality) {
    switch (quality) {
      case 'Optimal':
        return Colors.green;
      case 'Moderate':
        return Colors.orange;
      default:
        return Colors.red;
    }
  }

  double _calculateProgress(double temperature) {
    return (temperature.clamp(0.0, 80.0) / 80.0);
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year} '
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _formatLabel(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('MMM d').format(date);
    } catch (e) {
      return dateStr;
    }
  }
}

class _ChartPoint {
  final String x;
  final double y;
  _ChartPoint(this.x, this.y);
}

