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
    
    // Cycle settings - active/rest pattern
    int? activeMinutes,      // e.g., 1, 3, 5
    int? restMinutes,        // e.g., 59, 57, 55
    
    // Phase tracking for countdown synchronization
    String? currentPhase,    // 'active', 'resting', or 'stopped'
    DateTime? phaseStartTime, // When current phase started
    
    String? status,
    DateTime? startedAt,
    DateTime? completedAt,
    int? totalRuntimeSeconds,
    DateTime? timestamp,
  }) = _CycleRecommendation;

  const CycleRecommendation._();

  // ===== FIRESTORE CONVERSION =====

  /// Create from Firestore document
  static CycleRecommendation fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return CycleRecommendation(
      id: doc.id,
      category: data['category'] ?? 'cycles',
      controllerType: data['controllerType'] ?? '',
      machineId: data['machineId'],
      userId: data['userId'],
      batchId: data['batchId'],
      activeMinutes: data['activeMinutes'] as int?,
      restMinutes: data['restMinutes'] as int?,
      currentPhase: data['currentPhase'] as String?,
      phaseStartTime: (data['phaseStartTime'] as Timestamp?)?.toDate(),
      status: data['status'],
      startedAt: (data['startedAt'] as Timestamp?)?.toDate(),
      completedAt: (data['completedAt'] as Timestamp?)?.toDate(),
      totalRuntimeSeconds: data['totalRuntimeSeconds'],
      timestamp: (data['timestamp'] as Timestamp?)?.toDate(), 
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
      if (activeMinutes != null) 'activeMinutes': activeMinutes,
      if (restMinutes != null) 'restMinutes': restMinutes,
      if (currentPhase != null) 'currentPhase': currentPhase,
      if (phaseStartTime != null) 'phaseStartTime': Timestamp.fromDate(phaseStartTime!),
      if (status != null) 'status': status,
      if (startedAt != null) 'startedAt': Timestamp.fromDate(startedAt!),
      if (completedAt != null) 'completedAt': Timestamp.fromDate(completedAt!),
      if (totalRuntimeSeconds != null) 'totalRuntimeSeconds': totalRuntimeSeconds,
      if (timestamp != null) 'timestamp': Timestamp.fromDate(timestamp!),
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
  
  /// Get total cycle duration (active + rest) in minutes
  int get cycleDurationMinutes => (activeMinutes ?? 0) + (restMinutes ?? 0);
  
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
  
  /// Get display value (formatted active/rest pattern)
  String get value {
    if (activeMinutes == null || restMinutes == null) {
      return 'No pattern set';
    }
    return '$activeMinutes min active / $restMinutes min rest';
  }
  
  /// Get description (formatted cycle pattern)
  String get description => 
      'Cycle: ${activeMinutes ?? 0}min ON, ${restMinutes ?? 0}min OFF (${cycleDurationMinutes}min total)';
}