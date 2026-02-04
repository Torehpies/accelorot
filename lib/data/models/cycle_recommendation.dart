// lib/data/models/cycle_recommendation.dart

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'cycle_recommendation.freezed.dart';

/// Model for individual cycle controller (drum or aerator)
@freezed
abstract class CycleRecommendation with _$CycleRecommendation {
  const factory CycleRecommendation({
    required String id,
    required String category, // 'cycles'
    required String controllerType, // 'drum_controller' or 'aerator'
    String? machineId,
    String? userId,
    String? batchId,

    // Cycle settings
    int? cycles,
    String? duration,
    int? completedCycles,
    String? status,
    DateTime? startedAt,
    DateTime? completedAt,
    int? totalRuntimeSeconds,
    DateTime? timestamp,
    
    // Pause-related fields
    DateTime? pausedAt,
    int? accumulatedRuntimeSeconds,
  }) = _CycleRecommendation;

  const CycleRecommendation._();

  // ===== FIRESTORE CONVERSION =====

  /// Create from Firestore document
  static CycleRecommendation fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // Helper to safely convert numeric values to int
    int? toInt(dynamic value, String fieldName) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is double) {
        // Check for NaN or Infinity
        if (value.isNaN) {
          print('⚠️ NaN detected in field: $fieldName (doc: ${doc.id})');
          return null;
        }
        if (value.isInfinite) {
          print('⚠️ Infinity detected in field: $fieldName (doc: ${doc.id})');
          return null;
        }
        return value.toInt();
      }
      if (value is String) return int.tryParse(value);
      return null;
    }

    return CycleRecommendation(
      id: doc.id,
      category: data['category'] ?? 'cycles',
      controllerType: data['controllerType'] ?? '',
      machineId: data['machineId'],
      userId: data['userId'],
      batchId: data['batchId'],
      cycles: toInt(data['cycles'], 'cycles'),
      duration: data['duration'],
      completedCycles: toInt(data['completedCycles'], 'completedCycles'),
      status: data['status'],
      startedAt: (data['startedAt'] as Timestamp?)?.toDate(),
      completedAt: (data['completedAt'] as Timestamp?)?.toDate(),
      totalRuntimeSeconds: toInt(data['totalRuntimeSeconds'], 'totalRuntimeSeconds'),
      timestamp: (data['timestamp'] as Timestamp?)?.toDate(),
      pausedAt: (data['pausedAt'] as Timestamp?)?.toDate(),
      accumulatedRuntimeSeconds: toInt(data['accumulatedRuntimeSeconds'], 'accumulatedRuntimeSeconds'),
    );
  }

  /// Convert to Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      'category': category,
      'controllerType': controllerType,
      if (machineId != null) 'machineId': machineId,
      if (userId != null) 'userId': userId,
      if (batchId != null) 'batchId': batchId,
      if (cycles != null) 'cycles': cycles,
      if (duration != null) 'duration': duration,
      if (completedCycles != null) 'completedCycles': completedCycles,
      if (status != null) 'status': status,
      if (startedAt != null) 'startedAt': Timestamp.fromDate(startedAt!),
      if (completedAt != null) 'completedAt': Timestamp.fromDate(completedAt!),
      if (totalRuntimeSeconds != null)
        'totalRuntimeSeconds': totalRuntimeSeconds,
      if (pausedAt != null) 'pausedAt': Timestamp.fromDate(pausedAt!),
      if (accumulatedRuntimeSeconds != null)
        'accumulatedRuntimeSeconds': accumulatedRuntimeSeconds,
    };
  }

  // ===== DATA LOGIC HELPERS =====

  /// Check if this is a cycle
  bool get isCycle => category.toLowerCase() == 'cycles';

  /// Check if this is a drum controller
  bool get isDrumController => controllerType == 'drum_controller';

  /// Check if this is an aerator
  bool get isAerator => controllerType == 'aerator';

  /// Check if controller is running
  bool get isRunning => status == 'running';

  /// Check if controller is completed
  bool get isCompleted => status == 'completed';

  // ===== COMPUTED/DERIVED PROPERTIES =====

  /// Get display title
  String get title {
    switch (controllerType) {
      case 'drum_controller':
        return 'Drum Controller';
      case 'aerator':
        return 'Aerator';
      default:
        return 'Controller';
    }
  }

  /// Get display value (formatted cycles)
  String get value => cycles != null ? '$cycles cycles' : '0 cycles';

  /// Get description (formatted duration and cycles)
  String get description =>
      'Duration: ${duration ?? "N/A"}, Cycles: ${cycles ?? 0}';
}
