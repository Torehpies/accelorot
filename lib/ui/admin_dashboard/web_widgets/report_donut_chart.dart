// lib/ui/web_admin_home/widgets/report_donut_chart.dart
import 'package:flutter/material.dart';
import 'dart:math' as math;

class ReportDonutChart extends StatefulWidget {
  final Map<String, int> reportStatus;

  const ReportDonutChart({super.key, required this.reportStatus});

  @override
  State<ReportDonutChart> createState() => _ReportDonutChartState();
}

class _ReportDonutChartState extends State<ReportDonutChart> {
  int? _hoveredIndex;

  @override
  Widget build(BuildContext context) {
    final total = widget.reportStatus.values.reduce((a, b) => a + b);
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
                            MouseRegion(
                              onHover: (event) {
                                final index = _hitTest(
                                  event.localPosition,
                                  Size(size, size),
                                  widget.reportStatus,
                                );
                                if (index != _hoveredIndex) {
                                  setState(() => _hoveredIndex = index);
                                }
                              },
                              onExit: (_) => setState(() => _hoveredIndex = null),
                              child: CustomPaint(
                                painter: DonutPainter(
                                  widget.reportStatus,
                                  colors,
                                  hoveredIndex: _hoveredIndex,
                                ),
                                size: Size(size, size),
                              ),
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
                          if (_hoveredIndex != null && total > 0)
                            Positioned(
                              bottom: 8,
                              child: _HoverPill(
                                label: widget.reportStatus.keys
                                    .elementAt(_hoveredIndex!),
                                value: widget.reportStatus.values
                                    .elementAt(_hoveredIndex!)
                                    .toString(),
                                percentage: _percentForIndex(
                                  _hoveredIndex!,
                                  total,
                                  widget.reportStatus,
                                ),
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
            children: widget.reportStatus.entries.map((e) {
              final color =
                  colors[widget.reportStatus.keys.toList().indexOf(e.key)];
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
  final int? hoveredIndex;

  DonutPainter(this.status, this.colors, {this.hoveredIndex});

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
      paint.strokeWidth = i == hoveredIndex ? strokeWidth * 1.08 : strokeWidth;
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

class _HoverPill extends StatelessWidget {
  final String label;
  final String value;
  final String percentage;

  const _HoverPill({
    required this.label,
    required this.value,
    required this.percentage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        '$label: $value ($percentage)',
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Color(0xFF374151),
        ),
      ),
    );
  }
}

String _percentForIndex(
  int index,
  int total,
  Map<String, int> status,
) {
  if (total == 0) return '0%';
  final value = status.values.elementAt(index);
  final pct = (value / total) * 100;
  return '${pct.toStringAsFixed(0)}%';
}

int? _hitTest(
  Offset position,
  Size size,
  Map<String, int> status,
) {
  final center = Offset(size.width / 2, size.height / 2);
  final radius = math.min(size.width, size.height) / 2 - 20;
  final strokeWidth = radius * 0.50;
  final innerRadius = radius - strokeWidth / 2;
  final outerRadius = radius + strokeWidth / 2;

  final dx = position.dx - center.dx;
  final dy = position.dy - center.dy;
  final distance = math.sqrt(dx * dx + dy * dy);
  if (distance < innerRadius || distance > outerRadius) return null;

  final angle = math.atan2(dy, dx);
  double normalized = angle + math.pi / 2;
  if (normalized < 0) normalized += 2 * math.pi;

  final total = status.values.reduce((a, b) => a + b);
  double start = 0;
  for (int i = 0; i < status.length; i++) {
    final value = status[status.keys.elementAt(i)]!;
    final sweep = (value / total) * 2 * math.pi;
    if (normalized >= start && normalized < start + sweep) {
      return i;
    }
    start += sweep;
  }
  return null;
}
