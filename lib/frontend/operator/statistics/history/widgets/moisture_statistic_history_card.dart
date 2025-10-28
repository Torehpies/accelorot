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

class MoistureStatisticHistoryCard extends StatelessWidget {
  final double currentMoisture;
  final List<double> dailyReadings; // Daily readings (e.g., 8 days)
  final DateTime? lastUpdated;
  final List<String>? labels;

  const MoistureStatisticHistoryCard({
    super.key,
    required this.currentMoisture,
    required this.dailyReadings,
    this.lastUpdated,
    this.labels,
  });

  @override
  Widget build(BuildContext context) {
    if (dailyReadings.isEmpty) {
      return _buildEmptyCard(context);
    }

    final quality = _getQuality(currentMoisture);
    final color = _getColorForQuality(quality);
    final now = DateTime.now();
    final dataLength = dailyReadings.length;

    // Generate daily chart data (e.g., "Oct 18", "Oct 19", ...)
    final List<ChartPoint> moistureData = List.generate(dataLength, (i) {
      final day = now.subtract(Duration(days: dataLength - 1 - i));
      final label = DateFormat('MMM d').format(day);
      return ChartPoint(label, dailyReadings[i].toDouble());
    });

    // Ideal range lines (40–60%)
    final List<ChartPoint> upperBound =
        moistureData.map((d) => ChartPoint(d.x, 60.0)).toList();
    final List<ChartPoint> lowerBound =
        moistureData.map((d) => ChartPoint(d.x, 40.0)).toList();

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
            'Ideal Range: 40–60%',
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: _calculateProgress(currentMoisture),
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation(color),
            minHeight: 8,
          ),
          const SizedBox(height: 16),
          const Text(
            'Trend (Last 8 Days)',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 120,
            width: double.infinity,
            child: SfCartesianChart(
              primaryXAxis: CategoryAxis(
                labelStyle: const TextStyle(fontSize: 9),
                majorGridLines:
                    const MajorGridLines(width: 0.5, color: Colors.grey),
                interval: 1,
              ),
              primaryYAxis: NumericAxis(
                minimum: 0,
                maximum: 100,
                interval: 20,
                majorGridLines:
                    const MajorGridLines(width: 0.5, color: Colors.grey),
                labelStyle: const TextStyle(fontSize: 9),
              ),
              plotAreaBorderWidth: 0,
              margin: EdgeInsets.zero,
              series: <CartesianSeries>[
                // Main moisture trend
                LineSeries<ChartPoint, String>(
                  dataSource: moistureData,
                  xValueMapper: (data, _) => data.x,
                  yValueMapper: (data, _) => data.y,
                  color: Colors.blue,
                  width: 2,
                  markerSettings: const MarkerSettings(isVisible: true),
                ),
                // Ideal upper bound (60%)
                LineSeries<ChartPoint, String>(
                  dataSource: upperBound,
                  xValueMapper: (data, _) => data.x,
                  yValueMapper: (data, _) => data.y,
                  color: Colors.red,
                  dashArray: const [5, 5],
                  width: 1,
                ),
                // Ideal lower bound (40%)
                LineSeries<ChartPoint, String>(
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
        ],
      ),
    );
  }

  // ===================== Helper Widgets =====================

  Widget _buildHeader(BuildContext context, Color color) {
    return Row(
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
        child:
            Text('No moisture data', style: TextStyle(color: Colors.grey[600])),
      ),
    );
  }

  // ===================== Utility Methods =====================

  String _getQuality(double moisture) {
    if (moisture >= 40 && moisture <= 60) {
      return 'Excellent';
    }
    if ((moisture >= 30 && moisture < 40) ||
        (moisture > 60 && moisture <= 70)) {
      return 'Good';
    }
    return 'Critical';
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
    return moisture.clamp(0.0, 100.0) / 100.0;
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM d, yyyy – HH:mm').format(date);
  }
}
