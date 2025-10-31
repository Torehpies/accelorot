// lib/frontend/operator/dashboard/cycles/widgets/system_action_buttons.dart

import 'package:flutter/material.dart';
import '../models/system_status.dart';

class SystemActionButtons extends StatelessWidget {
  final SystemStatus status;
  final VoidCallback onStart;
  final VoidCallback onStop;
  final VoidCallback onTogglePause;

  const SystemActionButtons({
    super.key,
    required this.status,
    required this.onStart,
    required this.onStop,
    required this.onTogglePause,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: _buildButtons(context),
    );
  }

  Widget _buildButtons(BuildContext context) {
    switch (status) {
      case SystemStatus.idle:
      case SystemStatus.stopped:
        return _buildStartButton();
      
      case SystemStatus.running:
        return _buildRunningButtons(context);
      
      case SystemStatus.paused:
        return _buildPausedButtons(context);
    }
  }

  Widget _buildStartButton() {
    return ElevatedButton.icon(
      onPressed: onStart,
      icon: const Icon(Icons.play_arrow, size: 18),
      label: Text(
        status == SystemStatus.stopped ? 'Start New Cycle' : 'Start',
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF14B8A6), // Teal
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 32,
          vertical: 14,
        ),
      ),
    );
  }

  Widget _buildRunningButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton.icon(
          onPressed: onTogglePause,
          icon: const Icon(Icons.pause, size: 18),
          label: const Text(
            'Pause',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFF59E0B), // Amber
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 14,
            ),
          ),
        ),
        const SizedBox(width: 12),
        ElevatedButton.icon(
          onPressed: () => _showStopConfirmation(context),
          icon: const Icon(Icons.stop, size: 18),
          label: const Text(
            'Stop',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFEF4444), // Red
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPausedButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton.icon(
          onPressed: onTogglePause,
          icon: const Icon(Icons.play_arrow, size: 18),
          label: const Text(
            'Resume',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF14B8A6), // Teal
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 14,
            ),
          ),
        ),
        const SizedBox(width: 12),
        ElevatedButton.icon(
          onPressed: () => _showStopConfirmation(context),
          icon: const Icon(Icons.stop, size: 18),
          label: const Text(
            'Stop',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFEF4444), // Red
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }

  void _showStopConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Color(0xFFF59E0B)),
            SizedBox(width: 8),
            Text('Stop Drum Rotation?'),
          ],
        ),
        content: const Text(
          'This will stop the current cycle. You\'ll need to start a new cycle to continue.',
          style: TextStyle(fontSize: 14),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              onStop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Stop Cycle'),
          ),
        ],
      ),
    );
  }
}