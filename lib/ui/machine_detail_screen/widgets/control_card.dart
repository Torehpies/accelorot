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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFD0DFE9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF7C909C)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Title
          Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.grey[500],
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 10),
          // Timer
          Text(
            timerValue,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 14),
          // Action Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: isRunning
                    ? const Color(0xFFFFEBEE)
                    : const Color(0xFFD9D9D9),
                foregroundColor: isRunning
                    ? const Color(0xFFD32F2F)
                    : Colors.black87,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                buttonLabel,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
