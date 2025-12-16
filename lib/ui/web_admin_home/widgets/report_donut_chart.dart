// lib/ui/web_admin_home/widgets/report_donut_chart.dart

import 'package:flutter/material.dart';
import 'dart:math' as math; // ✅ Import math with alias

class ReportDonutChart extends StatelessWidget {
  final Map<String, int> reportStatus;

  const ReportDonutChart({
    super.key,
    required this.reportStatus,
  });

  @override
  Widget build(BuildContext context) {
    final total = reportStatus.values.reduce((a, b) => a + b);
    final colors = [
      Colors.green[900]!,
      Colors.green[700]!,
      Colors.green[500]!,
      Colors.green[300]!,
    ];

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Report Status', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),
            SizedBox(
              height: 200,
              width: 200,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CustomPaint(
                    painter: DonutPainter(reportStatus, colors),
                  ),
                  Text('$total',
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text('Legend:', style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 5),
            Wrap(
              spacing: 10,
              runSpacing: 5,
              children: reportStatus.entries.map((e) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      color: colors[reportStatus.keys.toList().indexOf(e.key)],
                    ),
                    const SizedBox(width: 5),
                    Text(e.key, style: Theme.of(context).textTheme.bodyMedium),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
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
    // ✅ Use math.min
    final radius = math.min(size.width, size.height) / 2 - 10;
    final paint = Paint()
      ..strokeWidth = 30
      ..style = PaintingStyle.stroke;

    double startAngle = -math.pi / 2; // Start from top (12 o'clock)
    final total = status.values.reduce((a, b) => a + b);

    for (int i = 0; i < status.length; i++) {
      final key = status.keys.elementAt(i);
      final value = status[key]!;
      // ✅ Use math.pi
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

    // Draw inner white circle to make it a donut
    final innerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius - 15, innerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}