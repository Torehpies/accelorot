/// Model for admin dashboard statistics
class AdminStats {
  final int userCount; // Total operators (including archived)
  final int machineCount; // Total machines (including archived)

  AdminStats({
    required this.userCount,
    required this.machineCount,
  });

  /// Create a copy with modified fields
  AdminStats copyWith({
    int? userCount,
    int? machineCount,
  }) {
    return AdminStats(
      userCount: userCount ?? this.userCount,
      machineCount: machineCount ?? this.machineCount,
    );
  }

  /// Create from map (if needed for Firestore)
  factory AdminStats.fromMap(Map<String, dynamic> map) {
    return AdminStats(
      userCount: map['userCount'] ?? 0,
      machineCount: map['machineCount'] ?? 0,
    );
  }

  /// Convert to map (if needed for Firestore)
  Map<String, dynamic> toMap() {
    return {
      'userCount': userCount,
      'machineCount': machineCount,
    };
  }
}