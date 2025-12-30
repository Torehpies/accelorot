
import 'package:flutter/material.dart';
import 'dart:math' as math;

class StatusChart extends StatelessWidget {
  const StatusChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Donut Chart
        SizedBox(
          width: 200,
          height: 200,
          child: CustomPaint(
            painter: DonutChartPainter(),
          ),
        ),
        const SizedBox(height: 24),
        // Legend
        Wrap(
          spacing: 16,
          runSpacing: 12,
          alignment: WrapAlignment.center,
          children: [
            _buildLegendItem('Open', const Color(0xFF059669)),
            _buildLegendItem('Closed', const Color(0xFF34D399)),
            _buildLegendItem('In Progress', const Color(0xFF065F46)),
            _buildLegendItem('Pending', const Color(0xFF6EE7B7)),
          ],
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF6B7280),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// Custom Painter for Donut Chart
class DonutChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    final strokeWidth = 30.0;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Sample data percentages (total should be close to 360 degrees)
    final segments = [
      {'color': const Color(0xFF059669), 'percentage': 0.25}, // Open
      {'color': const Color(0xFF34D399), 'percentage': 0.30}, // Closed
      {'color': const Color(0xFF065F46), 'percentage': 0.25}, // In Progress
      {'color': const Color(0xFF6EE7B7), 'percentage': 0.20}, // Pending
    ];

    double startAngle = -math.pi / 2; // Start from top

    for (var segment in segments) {
      paint.color = segment['color'] as Color;
      final sweepAngle = 2 * math.pi * (segment['percentage'] as double);

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
        startAngle,
        sweepAngle,
        false,
        paint,
      );

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}