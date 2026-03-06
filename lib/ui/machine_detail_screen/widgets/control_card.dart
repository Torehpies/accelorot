// lib/ui/machine_detail_screen/widgets/control_card.dart

import 'package:flutter/material.dart';

class ControlCard extends StatelessWidget {
  final String title;
  final String timerValue;
  final String buttonLabel;
  final VoidCallback? onPressed;
  final bool isRunning;

  const ControlCard({
    super.key,
    required this.title,
    required this.timerValue,
    required this.buttonLabel,
    this.onPressed,
    this.isRunning = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFD0DFE9),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF7C909C), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Title
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Color(0xFF789CA4),
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 6),
          // Timer
          Text(
            timerValue,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: Colors.black,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 10),
          // Action Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: isRunning
                    ? const Color(0xFFFFEBEE)
                    : const Color(0xFFEAF4FB),
                foregroundColor: isRunning
                    ? const Color(0xFFD32F2F)
                    : const Color(0xFF3B717B),
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                buttonLabel,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
