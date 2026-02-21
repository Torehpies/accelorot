// lib/ui/qr_scan/widgets/scan_frame_overlay.dart

import 'package:flutter/material.dart';

/// Teal corner frame overlay for the QR scanner viewfinder
class ScanFrameOverlay extends StatelessWidget {
  final double size;
  final double cornerLength;
  final double cornerWidth;
  final Color cornerColor;

  const ScanFrameOverlay({
    super.key,
    this.size = 220.0,
    this.cornerLength = 32.0,
    this.cornerWidth = 3.0,
    this.cornerColor = const Color(0xFF4ECDC4),
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _ScanFramePainter(
          cornerLength: cornerLength,
          cornerWidth: cornerWidth,
          cornerColor: cornerColor,
        ),
      ),
    );
  }
}

class _ScanFramePainter extends CustomPainter {
  final double cornerLength;
  final double cornerWidth;
  final Color cornerColor;

  _ScanFramePainter({
    required this.cornerLength,
    required this.cornerWidth,
    required this.cornerColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = cornerColor
      ..strokeWidth = cornerWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final w = size.width;
    final h = size.height;

    // Top-left
    canvas.drawLine(const Offset(0, 0), Offset(cornerLength, 0), paint);
    canvas.drawLine(const Offset(0, 0), Offset(0, cornerLength), paint);

    // Top-right
    canvas.drawLine(Offset(w, 0), Offset(w - cornerLength, 0), paint);
    canvas.drawLine(Offset(w, 0), Offset(w, cornerLength), paint);

    // Bottom-left
    canvas.drawLine(Offset(0, h), Offset(cornerLength, h), paint);
    canvas.drawLine(Offset(0, h), Offset(0, h - cornerLength), paint);

    // Bottom-right
    canvas.drawLine(Offset(w, h), Offset(w - cornerLength, h), paint);
    canvas.drawLine(Offset(w, h), Offset(w, h - cornerLength), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
