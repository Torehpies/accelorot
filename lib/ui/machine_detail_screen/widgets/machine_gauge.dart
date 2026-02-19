// lib/ui/machine_detail_screen/widgets/machine_gauge.dart

import 'package:flutter/material.dart';
import 'package:gauge_indicator/gauge_indicator.dart';

class MachineGauge extends StatelessWidget {
  final double value;
  final double min;
  final double max;
  final String label;
  final String unit;

  const MachineGauge({
    super.key,
    required this.value,
    required this.min,
    required this.max,
    required this.label,
    this.unit = '',
  });

  Color _getValueColor() {
    final range = max - min;
    final third = range / 3;

    if (value < min + third) {
      return const Color(0xFF4285F4);
    } else if (value < min + (2 * third)) {
      return const Color(0xFF4CAF50);
    } else {
      return const Color(0xFFFF5252);
    }
  }

  @override
  Widget build(BuildContext context) {
    const colorBlue = Color(0xFF4285F4);
    const colorGreen = Color(0xFF4CAF50);
    const colorRed = Color(0xFFFF5252);

    final range = max - min;
    final third = range / 3;

    return LayoutBuilder(
      builder: (context, constraints) {
        final gaugeSize = constraints.maxWidth.isFinite ? constraints.maxWidth : 150.0;
        final visibleHeight = gaugeSize * 0.6;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: visibleHeight,
              width: gaugeSize,
              child: OverflowBox(
                maxHeight: gaugeSize,
                maxWidth: gaugeSize,
                alignment: Alignment.topCenter,
                child: SizedBox(
                  height: gaugeSize,
                  width: gaugeSize,
                  child: AnimatedRadialGauge(
                    duration: const Duration(seconds: 1),
                    curve: Curves.easeOutQuad,
                    value: value,
                    axis: GaugeAxis(
                      min: min,
                      max: max,
                      degrees: 180,
                      style: GaugeAxisStyle(
                        thickness: gaugeSize * 0.09,
                        background: Colors.transparent,
                        segmentSpacing: 3,
                      ),
                      pointer: GaugePointer.triangle(
                        width: gaugeSize * 0.10,
                        height: gaugeSize * 0.10,
                        color: const Color(0xFF193663),
                        border: const GaugePointerBorder(
                          color: Colors.white,
                          width: 1,
                        ),
                        position: GaugePointerPosition.surface(
                          offset: Offset(0, gaugeSize * 0.04),
                        ),
                      ),
                      progressBar: null,
                      segments: [
                        GaugeSegment(
                          from: min,
                          to: min + third,
                          color: colorBlue,
                          cornerRadius: const Radius.circular(4),
                        ),
                        GaugeSegment(
                          from: min + third,
                          to: min + (2 * third),
                          color: colorGreen,
                          cornerRadius: const Radius.circular(4),
                        ),
                        GaugeSegment(
                          from: min + (2 * third),
                          to: max,
                          color: colorRed,
                          cornerRadius: const Radius.circular(4),
                        ),
                      ],
                    ),
                    builder: (context, child, value) => const SizedBox.shrink(),
                  ),
                ),
              ),
            ),
            Text(
              '${value.toInt()}$unit',
              style: TextStyle(
                fontFamily: 'dm-sans',
                color: _getValueColor(),
                fontSize: gaugeSize * 0.14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'dm-sans',
                color: Colors.grey[600],
                fontSize: gaugeSize * 0.09,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        );
      },
    );
  }
}