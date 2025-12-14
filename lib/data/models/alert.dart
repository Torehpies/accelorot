// lib/data/models/alert.dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../utils/parsers.dart';

part 'alert.freezed.dart';

/// Pure data model for sensor alerts
/// No UI concerns - just data
@freezed
abstract class Alert with _$Alert {
  const factory Alert({
    required String id,
    required String machineId,
    required String sensorType, // 'temperature', 'moisture', 'air quality'
    required double readingValue,
    required double threshold,
    required String status, // 'above', 'below', 'normal'
    required String message,
    required DateTime timestamp,
    Map<String, dynamic>? readings, // Additional sensor readings
  }) = _Alert;
  
  const Alert._();

  // ===== FIRESTORE CONVERSION =====
  
  /// Create from Firestore document
  static Alert fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    
    return Alert(
      id: doc.id,
      machineId: data['machine_id'] ?? '',
      sensorType: data['sensor_type'] ?? '',
      readingValue: DataParsers.parseDouble(data['reading_value']),
      threshold: DataParsers.parseDouble(data['threshold']),
      status: data['status'] ?? '',
      message: data['message'] ?? '',
      timestamp: DataParsers.parseTimestamp(data['timestamp']),
      readings: data['readings'] as Map<String, dynamic>?,
    );
  }

  /// Create from map (for backwards compatibility)
  static Alert fromMap(Map<String, dynamic> data) {
    return Alert(
      id: data['id'] ?? '',
      machineId: data['machine_id'] ?? '',
      sensorType: data['sensor_type'] ?? '',
      readingValue: DataParsers.parseDouble(data['reading_value']),
      threshold: DataParsers.parseDouble(data['threshold']),
      status: data['status'] ?? '',
      message: data['message'] ?? '',
      timestamp: DataParsers.parseTimestamp(data['timestamp']),
      readings: data['readings'] as Map<String, dynamic>?,
    );
  }

  /// Convert to Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      'machine_id': machineId,
      'sensor_type': sensorType,
      'reading_value': readingValue,
      'threshold': threshold,
      'status': status,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'readings': readings,
    };
  }
}