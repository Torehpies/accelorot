// lib/frontend/operator/dashboard/cycles/models/drum_rotation_settings.dart

class DrumRotationSettings {
  int cycles;
  String period;
  
  // For future Firestore integration
  DateTime? lastCycleCompleted;
  Duration totalRuntime;

  DrumRotationSettings({
    this.cycles = 50,
    this.period = "1 hour",
    this.lastCycleCompleted,
    this.totalRuntime = Duration.zero,
  });

  // Reset to defaults (used when starting new batch)
  void reset() {
    cycles = 50;
    period = "1 hour";
    lastCycleCompleted = null;
    totalRuntime = Duration.zero;
  }

  // Create a copy
  DrumRotationSettings copyWith({
    int? cycles,
    String? period,
    DateTime? lastCycleCompleted,
    Duration? totalRuntime,
  }) {
    return DrumRotationSettings(
      cycles: cycles ?? this.cycles,
      period: period ?? this.period,
      lastCycleCompleted: lastCycleCompleted ?? this.lastCycleCompleted,
      totalRuntime: totalRuntime ?? this.totalRuntime,
    );
  }

  // For future Firestore
  Map<String, dynamic> toMap() {
    return {
      'cycles': cycles,
      'period': period,
      'lastCycleCompleted': lastCycleCompleted?.toIso8601String(),
      'totalRuntimeSeconds': totalRuntime.inSeconds,
    };
  }

  factory DrumRotationSettings.fromMap(Map<String, dynamic> map) {
    return DrumRotationSettings(
      cycles: map['cycles'] ?? 50,
      period: map['period'] ?? "1 hour",
      lastCycleCompleted: map['lastCycleCompleted'] != null
          ? DateTime.parse(map['lastCycleCompleted'])
          : null,
      totalRuntime: Duration(seconds: map['totalRuntimeSeconds'] ?? 0),
    );
  }
}