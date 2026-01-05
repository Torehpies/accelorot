// lib/frontend/operator/dashboard/cycles/models/system_status.dart

import 'package:flutter/material.dart';

enum SystemStatus {
  idle,
  running,
  paused,
  stopped;

  Color get color {
    switch (this) {
      case SystemStatus.idle:
        return const Color(0xFF6B7280); // Gray
      case SystemStatus.running:
        return const Color(0xFF14B8A6); // Teal
      case SystemStatus.paused:
        return const Color(0xFFF59E0B); // Amber
      case SystemStatus.stopped:
        return const Color(0xFFEF4444); // Red
    }
  }

  IconData get icon {
    switch (this) {
      case SystemStatus.idle:
        return Icons.circle_outlined;
      case SystemStatus.running:
        return Icons.play_circle;
      case SystemStatus.paused:
        return Icons.pause_circle;
      case SystemStatus.stopped:
        return Icons.stop_circle;
    }
  }

  String get displayName {
    switch (this) {
      case SystemStatus.idle:
        return 'Idle';
      case SystemStatus.running:
        return 'Running';
      case SystemStatus.paused:
        return 'Paused';
      case SystemStatus.stopped:
        return 'Stopped';
    }
  }
}
