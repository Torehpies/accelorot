import 'sensor_reading_model.dart';

class MoistureModel extends SensorReadingModel {
  MoistureModel({
    required super.id,
    required super.value,
    super.timestamp,
  });

  String get quality {
    if (value >= 40 && value <= 60) return 'Excellent';
    if ((value >= 30 && value < 40) || (value > 60 && value <= 70)) {
      return 'Good';
    }
    return 'Critical';
  }

  factory MoistureModel.fromMap(Map<String, dynamic> map) {
    return MoistureModel(
      id: map['id'] as String,
      value: (map['value'] ?? 0).toDouble(),
      timestamp: SensorReadingModel.parseTimestamp(map['timestamp']),
    );
  }
}
