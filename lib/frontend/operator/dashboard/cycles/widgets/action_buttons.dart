// lib/frontend/operator/dashboard/cycles/system_card_widgets/system_action_buttons.dart

import 'package:flutter/material.dart';

class SystemActionButtons extends StatelessWidget {
  final bool isRunning;
  final bool isPaused;
  final VoidCallback onStart;
  final VoidCallback onStop;
  final VoidCallback onTogglePause;

  const SystemActionButtons({
    super.key,
    required this.isRunning,
    required this.isPaused,
    required this.onStart,
    required this.onStop,
    required this.onTogglePause,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: isRunning
          ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // --- Pause/Resume Button ---
                ElevatedButton(
                  onPressed: onTogglePause,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isPaused
                        ? const Color.fromARGB(255, 14, 138, 255) // Blue for Resume
                        : const Color.fromARGB(255, 255, 185, 32), // Yellow for Pause
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 14,
                    ),
                  ),
                  child: Text(
                    isPaused ? "Resume" : "Pause",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // --- Stop Button ---
                ElevatedButton(
                  onPressed: onStop,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 14,
                    ),
                  ),
                  child: const Text(
                    "Stop",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            )
          // --- Start Button ---
          : ElevatedButton(
              onPressed: onStart,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E5339), // Custom Green
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 50,
                  vertical: 14,
                ),
              ),
              child: const Text(
                'Start',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
    );
  }
}