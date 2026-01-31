class SensorReadingModel {
  final String id;
  final double value;
  final DateTime? timestamp;

  SensorReadingModel({required this.id, required this.value, this.timestamp});

  /// Shared timestamp parser (public so children can access)
  static DateTime? parseTimestamp(dynamic timestamp) {
    if (timestamp == null) return null;
    if (timestamp is DateTime) return timestamp;
    if (timestamp is String) {
      try {
        return DateTime.parse(timestamp);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  factory SensorReadingModel.fromMap(Map<String, dynamic> map) {
    return SensorReadingModel(
      id: map['id'] as String,
      value: (map['value'] ?? 0).toDouble(),
      timestamp: parseTimestamp(map['timestamp']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'value': value,
      'timestamp': timestamp?.toIso8601String(),
    };
  }
}
