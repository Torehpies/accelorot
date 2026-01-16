import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

/// Modern statistics card matching the design mockup
class WebStatCard extends StatelessWidget {
  final String title;
  final String description;
  final String value;
  final String unit;
  final String idealRange;
  final double progress;
  final Color valueColor;
  final Color progressColor;
  final String trendText;
  final List<String> moreInfoItems;
  final List<Map<String, dynamic>> chartData;

  const WebStatCard({
    super.key,
    required this.title,
    required this.description,
    required this.value,
    required this.unit,
    required this.idealRange,
    required this.progress,
    required this.valueColor,
    required this.progressColor,
    required this.trendText,
    required this.moreInfoItems,
    required this.chartData,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title and Description
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF9CA3AF),
            ),
          ),
          const SizedBox(height: 20),

          // Large Value
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: valueColor,
                  height: 1.0,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                unit,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: valueColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Ideal Range and Progress Bar
          Text(
            'Ideal Range: $idealRange',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: const Color(0xFFE5E7EB),
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 20),

          // Chart
          SizedBox(
            height: 140,
            child: SfCartesianChart(
              plotAreaBorderWidth: 0,
              margin: EdgeInsets.zero,
              primaryXAxis: CategoryAxis(
                labelStyle: const TextStyle(fontSize: 10, color: Color(0xFF9CA3AF)),
                majorGridLines: const MajorGridLines(width: 0),
                axisLine: const AxisLine(width: 0),
              ),
              primaryYAxis: NumericAxis(
                isVisible: false,
                majorGridLines: const MajorGridLines(width: 0),
              ),
              series: <CartesianSeries>[
                SplineAreaSeries<Map<String, dynamic>, String>(
                  dataSource: chartData,
                  xValueMapper: (data, _) => data['month'] as String,
                  yValueMapper: (data, _) => data['value'] as double,
                  color: valueColor.withValues(alpha: 0.2),
                  borderColor: valueColor,
                  borderWidth: 2,
                  markerSettings: MarkerSettings(
                    isVisible: true,
                    color: valueColor,
                    borderColor: Colors.white,
                    borderWidth: 2,
                    height: 6,
                    width: 6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Trend Text
          Text(
            trendText,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 16),

          // More Information Section
          const Text(
            'More information:',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 8),
          ...moreInfoItems.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '• ',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        item,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF9CA3AF),
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
