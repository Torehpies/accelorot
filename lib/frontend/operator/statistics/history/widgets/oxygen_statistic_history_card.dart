// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';

/// A reusable chart point model
class ChartPoint {
  final String x;
  final double y;
  ChartPoint(this.x, this.y);
}

class OxygenStatisticHistoryCard extends StatelessWidget {
  final double currentOxygen;
  final List<double> dailyReadings;
  final DateTime? lastUpdated;
  final List<String>? labels;

  const OxygenStatisticHistoryCard({
    super.key,
    required this.currentOxygen,
    required this.dailyReadings,
    this.lastUpdated,
    this.labels,
  });

  @override
  Widget build(BuildContext context) {
    if (dailyReadings.isEmpty) {
      return _buildEmptyCard(context);
    }

    final quality = _getQuality(currentOxygen);
    final color = _getColorForQuality(quality);
    final dataLength = dailyReadings.length;

    final List<ChartPoint> oxygenData = [];
    final List<ChartPoint> upperBound = [];
    final List<ChartPoint> lowerBound = [];

    for (int i = 0; i < dataLength; i++) {
      final label = (labels != null && i < labels!.length) 
          ? _formatLabel(labels![i]) 
          : 'Day ${i + 1}';
      
      oxygenData.add(ChartPoint(label, dailyReadings[i]));
      upperBound.add(ChartPoint(label, 1500.0));
      lowerBound.add(ChartPoint(label, 0.0));
    }

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
          _buildHeader(context, color),
          if (lastUpdated != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'Last updated: ${_formatDate(lastUpdated!)}',
                style: TextStyle(fontSize: 11, color: Colors.grey[600]),
              ),
            ),
          const SizedBox(height: 12),
          _buildQualityRow(color, quality),
          const SizedBox(height: 12),
          const Text(
            'Ideal Range: 0–1500 ppm',
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: _calculateProgress(currentOxygen),
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation(color),
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
                        maximum: 5000,
                        interval: 1000,
                        majorGridLines:
                            const MajorGridLines(width: 0.5, color: Colors.grey),
                        labelStyle: const TextStyle(fontSize: 9),
                      ),
                      plotAreaBorderWidth: 0,
                      margin: EdgeInsets.zero,
                      series: <CartesianSeries>[
                        LineSeries<ChartPoint, String>(
                          dataSource: oxygenData,
                          xValueMapper: (data, _) => data.x,
                          yValueMapper: (data, _) => data.y,
                          color: Colors.blue,
                          width: 2,
                          markerSettings: const MarkerSettings(isVisible: true),
                        ),
                        LineSeries<ChartPoint, String>(
                          dataSource: upperBound,
                          xValueMapper: (data, _) => data.x,
                          yValueMapper: (data, _) => data.y,
                          color: Colors.red,
                          dashArray: const [5, 5],
                          width: 1,
                        ),
                        LineSeries<ChartPoint, String>(
                          dataSource: lowerBound,
                          xValueMapper: (data, _) => data.x,
                          yValueMapper: (data, _) => data.y,
                          color: Colors.green,
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

  Widget _buildHeader(BuildContext context, Color color) {
    return Row(
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
          '${currentOxygen.toStringAsFixed(0)} ppm',
          style: Theme.of(context)
              .textTheme
              .headlineSmall
              ?.copyWith(fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }

  Widget _buildQualityRow(Color color, String quality) {
    return Row(
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
            color: Colors.green.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Center(
        child: Text('No oxygen data', style: TextStyle(color: Colors.grey[600])),
      ),
    );
  }

  String _getQuality(double ppm) {
    if (ppm <= 1500) return 'Excellent';
    if (ppm > 1500 && ppm <= 3000) return 'Good';
    if (ppm > 3000 && ppm <= 4000) return 'Fair';
    return 'Poor';
  }

  Color _getColorForQuality(String quality) {
    switch (quality) {
      case 'Excellent':
        return Colors.green;
      case 'Good':
        return Colors.orange;
      case 'Fair':
        return Colors.amber;
      default:
        return Colors.red;
    }
  }

  double _calculateProgress(double ppm) {
    return (ppm.clamp(0.0, 5000.0) / 5000.0);
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM d, yyyy – HH:mm').format(date);
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