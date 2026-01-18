// lib/frontend/operator/dashboard/cycles/models/drum_rotation_settings.dart

class DrumRotationSettings {
  int activeMinutes;
  int restMinutes;
  

  String currentPhase; // 'active', 'resting', or 'stopped'
  DateTime? phaseStartTime; 

  DateTime? lastCycleCompleted;
  Duration totalRuntime;

  DrumRotationSettings({
    this.activeMinutes = 1,
    this.restMinutes = 59,
    this.currentPhase = 'stopped',
    this.phaseStartTime,
    this.lastCycleCompleted,
    this.totalRuntime = Duration.zero,
  });


  Duration get remainingTime {
    if (currentPhase == 'stopped' || phaseStartTime == null) return Duration.zero;

    final elapsed = DateTime.now().difference(phaseStartTime!);
    final totalPhaseDuration = currentPhase == 'active' 
        ? Duration(minutes: activeMinutes) 
        : Duration(minutes: restMinutes);
    
    final remaining = totalPhaseDuration - elapsed;
    return remaining.isNegative ? Duration.zero : remaining;
  }

  /// Get pattern as string (e.g., "1/59")
  String get pattern => '$activeMinutes/$restMinutes';

  /// Set pattern from string (e.g., "1/59")
  void setPattern(String pattern) {
    final parts = pattern.split('/');
    if (parts.length == 2) {
      activeMinutes = int.tryParse(parts[0]) ?? 1;
      restMinutes = int.tryParse(parts[1]) ?? 59;
    }
  }

  // Reset to defaults (used when starting new batch)
  void reset() {
    activeMinutes = 1;
    restMinutes = 59;
    currentPhase = 'stopped';
    phaseStartTime = null;
    lastCycleCompleted = null;
    totalRuntime = Duration.zero;
  }

  // Create a copy
  DrumRotationSettings copyWith({
    int? activeMinutes,
    int? restMinutes,
    String? currentPhase,
    DateTime? phaseStartTime,
    DateTime? lastCycleCompleted,
    Duration? totalRuntime,
  }) {
    return DrumRotationSettings(
      activeMinutes: activeMinutes ?? this.activeMinutes,
      restMinutes: restMinutes ?? this.restMinutes,
      currentPhase: currentPhase ?? this.currentPhase,
      phaseStartTime: phaseStartTime ?? this.phaseStartTime,
      lastCycleCompleted: lastCycleCompleted ?? this.lastCycleCompleted,
      totalRuntime: totalRuntime ?? this.totalRuntime,
    );
  }

  // For Firestore
  Map<String, dynamic> toMap() {
    return {
      'activeMinutes': activeMinutes,
      'restMinutes': restMinutes,
      'currentPhase': currentPhase,
      'phaseStartTime': phaseStartTime?.toIso8601String(),
      'lastCycleCompleted': lastCycleCompleted?.toIso8601String(),
      'totalRuntimeSeconds': totalRuntime.inSeconds,
    };
  }

  factory DrumRotationSettings.fromMap(Map<String, dynamic> map) {
    return DrumRotationSettings(
      activeMinutes: map['activeMinutes'] as int? ?? 1,
      restMinutes: map['restMinutes'] as int? ?? 59,
      currentPhase: map['currentPhase'] as String? ?? 'stopped',
      phaseStartTime: map['phaseStartTime'] != null
          ? DateTime.parse(map['phaseStartTime'] as String)
          : null,
      lastCycleCompleted: map['lastCycleCompleted'] != null
          ? DateTime.parse(map['lastCycleCompleted'] as String)
          : null,
      totalRuntime: Duration(seconds: map['totalRuntimeSeconds'] as int? ?? 0),
    );
  }
}   