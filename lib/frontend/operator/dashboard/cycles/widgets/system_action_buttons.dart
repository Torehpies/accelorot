import 'package:flutter/material.dart';
import '../models/system_status.dart';
import 'stop_confirmation_dialog.dart';

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
    return Center(child: _buildButtons(context));
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
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
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
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFF59E0B),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          ),
        ),
        const SizedBox(width: 12),
        ElevatedButton.icon(
          onPressed: () async {
            final confirmed = await showStopConfirmationDialog(context);
            if (confirmed) onStop();
          },
          icon: const Icon(Icons.stop, size: 18),
          label: const Text(
            'Stop',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFEF4444),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
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
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF14B8A6),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          ),
        ),
        const SizedBox(width: 12),
        ElevatedButton.icon(
          onPressed: () async {
            final confirmed = await showStopConfirmationDialog(context);
            if (confirmed) onStop();
          },
          icon: const Icon(Icons.stop, size: 18),
          label: const Text(
            'Stop',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFEF4444),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          ),
        ),
      ],
    );
  }
}
