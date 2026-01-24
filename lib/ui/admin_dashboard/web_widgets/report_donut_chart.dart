// lib/ui/web_admin_home/widgets/report_donut_chart.dart
import 'package:flutter/material.dart';
import 'dart:math' as math;

class ReportDonutChart extends StatelessWidget {
  final Map<String, int> reportStatus;

  const ReportDonutChart({super.key, required this.reportStatus});

  @override
  Widget build(BuildContext context) {
    final total = reportStatus.values.reduce((a, b) => a + b);
    final colors = [
      const Color(0xFF065F46), // Dark green for Open
      const Color(0xFF059669), // Medium-dark green for In Progress
      const Color(0xFF10B981), // Medium green for Closed
      const Color(0xFF6EE7B7), // Light green for Pending
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Report Status',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Center(
              child: AspectRatio(
                aspectRatio: 1,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final size = constraints.maxWidth < constraints.maxHeight
                        ? constraints.maxWidth
                        : constraints.maxHeight;
                    return SizedBox(
                      width: size,
                      height: size,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          if (total > 0)
                            CustomPaint(
                              painter: DonutPainter(reportStatus, colors),
                              size: Size(size, size),
                            )
                          else
                            const Center(
                              child: Text(
                                "No data",
                                style: TextStyle(color: Color(0xFF9CA3AF)),
                              ),
                            ),
                          Text(
                            '$total',
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF111827),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Legend:',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: reportStatus.entries.map((e) {
              final color = colors[reportStatus.keys.toList().indexOf(e.key)];
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    e.key,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class DonutPainter extends CustomPainter {
  final Map<String, int> status;
  final List<Color> colors;

  DonutPainter(this.status, this.colors);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 20;
    final strokeWidth = radius * 0.50;
    final paint = Paint()
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    double startAngle = -math.pi / 2;
    final total = status.values.reduce((a, b) => a + b);

    for (int i = 0; i < status.length; i++) {
      final value = status[status.keys.elementAt(i)]!;
      final sweepAngle = (value / total) * 2 * math.pi;
      paint.color = colors[i];
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
      startAngle += sweepAngle;
    }

    final innerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius - strokeWidth / 2, innerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
