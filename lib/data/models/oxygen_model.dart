import 'sensor_reading_model.dart';

class OxygenModel extends SensorReadingModel {
  OxygenModel({required super.id, required super.value, super.timestamp});

  String get quality {
    if (value <= 1500) return 'Excellent';
    if (value <= 3000) return 'Good';
    if (value <= 4000) return 'Fair';
    return 'Poor';
  }

  factory OxygenModel.fromMap(Map<String, dynamic> map) {
    return OxygenModel(
      id: map['id'] as String,
      value: (map['value'] ?? 0).toDouble(),
      timestamp: SensorReadingModel.parseTimestamp(map['timestamp']),
    );
  }
}
