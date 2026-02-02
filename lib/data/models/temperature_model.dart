import 'sensor_reading_model.dart';

class TemperatureModel extends SensorReadingModel {
  TemperatureModel({required super.id, required super.value, super.timestamp});

  String get quality {
    if (value >= 55 && value <= 65) return 'Optimal';
    if ((value >= 40 && value < 55) || (value > 65 && value <= 70)) {
      return 'Moderate';
    }
    return 'Poor';
  }

  factory TemperatureModel.fromMap(Map<String, dynamic> map) {
    return TemperatureModel(
      id: map['id'] as String,
      value: (map['value'] ?? 0).toDouble(),
      timestamp: SensorReadingModel.parseTimestamp(map['timestamp']),
    );
  }
}
