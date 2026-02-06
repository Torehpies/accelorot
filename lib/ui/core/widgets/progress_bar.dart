import 'package:flutter/material.dart';

/// Simplified progress bar with clear visual hierarchy
/// Best for new users who need immediate understanding
class SimpleRangeProgressBar extends StatelessWidget {
  final double currentValue;
  final double minIdeal;
  final double maxIdeal;
  final double maxScale;
  final String unit;
  final Color primaryColor;
  final Color backgroundColor;

  const SimpleRangeProgressBar({
    super.key,
    required this.currentValue,
    required this.minIdeal,
    required this.maxIdeal,
    required this.maxScale,
    required this.unit,
    required this.primaryColor,
    required this.backgroundColor,
  });

  bool get isInIdealRange => currentValue >= minIdeal && currentValue <= maxIdeal;
  bool get isBelowIdeal => currentValue < minIdeal;

  Color get statusColor {
    if (isInIdealRange) return const Color(0xFF22C55E);
    if (isBelowIdeal) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }

  IconData get statusIcon {
    if (isInIdealRange) return Icons.check_circle;
    if (isBelowIdeal) return Icons.arrow_upward;
    return Icons.arrow_downward;
  }

  String get statusText {
    if (isInIdealRange) return 'Optimal';
    if (isBelowIdeal) return 'Too Low';
    return 'Too High';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Ideal range text
            Expanded(
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF4B5563),
                  ),
                  children: [
                    const TextSpan(
                      text: 'Ideal Range: ',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    TextSpan(
                      text: '$minIdeal$unit - $maxIdeal$unit',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF22C55E),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Status badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: statusColor.withOpacity(0.4),
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    statusIcon,
                    size: 14,
                    color: statusColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    statusText,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: statusColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Progress bar with labels
        Stack(
          clipBehavior: Clip.none,
          children: [
            Column(
              children: [
                // Top scale labels
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '0$unit',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF9CA3AF),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '${(maxScale / 2).toInt()}$unit',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF9CA3AF),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '${maxScale.toInt()}$unit',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF9CA3AF),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // The progress bar
                Container(
                  height: 28,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Stack(
                      children: [
                        // Background
                        Container(color: backgroundColor),
                        
                        // Ideal range highlight
                        CustomPaint(
                          size: Size(double.infinity, 28),
                          painter: IdealRangeHighlightPainter(
                            minPercent: (minIdeal / maxScale) * 100,
                            maxPercent: (maxIdeal / maxScale) * 100,
                          ),
                        ),
                        
                        // Progress fill
                        FractionallySizedBox(
                          widthFactor: (currentValue.clamp(0.0, maxScale) / maxScale),
                          alignment: Alignment.centerLeft,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  primaryColor,
                                  primaryColor.withOpacity(0.85),
                                ],
                              ),
                            ),
                          ),
                        ),
                        
                        // Ideal range borders
                        CustomPaint(
                          size: Size(double.infinity, 28),
                          painter: RangeBorderPainter(
                            minPercent: (minIdeal / maxScale) * 100,
                            maxPercent: (maxIdeal / maxScale) * 100,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            
            // Floating range indicators
            Positioned(
              top: 20, // Position between scale labels and progress bar
              left: 0,
              right: 0,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;
                  return Stack(
                    children: [
                      // Min ideal marker
                      Positioned(
                        left: ((minIdeal / maxScale) * width) - 24,
                        child: _RangeMarker(
                          label: minIdeal.toStringAsFixed(minIdeal % 1 == 0 ? 0 : 1),
                          unit: unit,
                        ),
                      ),
                      // Max ideal marker
                      Positioned(
                        left: ((maxIdeal / maxScale) * width) - 24,
                        child: _RangeMarker(
                          label: maxIdeal.toStringAsFixed(maxIdeal % 1 == 0 ? 0 : 1),
                          unit: unit,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _RangeMarker extends StatelessWidget {
  final String label;
  final String unit;

  const _RangeMarker({
    required this.label,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: const Color(0xFF22C55E),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF22C55E).withOpacity(0.15),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        '$label$unit',
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: Color(0xFF22C55E),
          letterSpacing: -0.3,
        ),
      ),
    );
  }
}

class IdealRangeHighlightPainter extends CustomPainter {
  final double minPercent;
  final double maxPercent;

  IdealRangeHighlightPainter({
    required this.minPercent,
    required this.maxPercent,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF22C55E).withOpacity(0.15)
      ..style = PaintingStyle.fill;

    final minX = (minPercent / 100) * size.width;
    final maxX = (maxPercent / 100) * size.width;

    canvas.drawRect(
      Rect.fromLTRB(minX, 0, maxX, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(IdealRangeHighlightPainter oldDelegate) => false;
}

class RangeBorderPainter extends CustomPainter {
  final double minPercent;
  final double maxPercent;

  RangeBorderPainter({
    required this.minPercent,
    required this.maxPercent,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF22C55E)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final minX = (minPercent / 100) * size.width;
    final maxX = (maxPercent / 100) * size.width;

    canvas.drawLine(
      Offset(minX, 3),
      Offset(minX, size.height - 3),
      paint,
    );
    canvas.drawLine(
      Offset(maxX, 3),
      Offset(maxX, size.height - 3),
      paint,
    );
  }

  @override
  bool shouldRepaint(RangeBorderPainter oldDelegate) => false;
}