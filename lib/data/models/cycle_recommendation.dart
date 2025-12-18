import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'cycle_recommendation.freezed.dart';

/// Model for a cycle containing both drum controller and aerator settings
@freezed
abstract class CycleRecommendation with _$CycleRecommendation {
  const factory CycleRecommendation({
    required String id,
    required String title,
    required String value,
    required String category, // 'recoms' or 'cycles'
    required String description,
    required DateTime timestamp,
    String? machineId,
    String? userId,
    String? batchId,
    
    // Drum Controller fields
    int? drumCycles,
    String? drumDuration,
    int? drumCompletedCycles,
    String? drumStatus, // 'idle', 'running', 'stopped', 'completed'
    DateTime? drumStartedAt,
    DateTime? drumCompletedAt,
    int? drumTotalRuntimeSeconds,
    
    // Aerator fields
    int? aeratorCycles,
    String? aeratorDuration,
    int? aeratorCompletedCycles,
    String? aeratorStatus, // 'idle', 'running', 'stopped', 'completed'
    DateTime? aeratorStartedAt,
    DateTime? aeratorCompletedAt,
    int? aeratorTotalRuntimeSeconds,
  }) = _CycleRecommendation;

  const CycleRecommendation._();

  // ===== FIRESTORE CONVERSION =====

  /// Create from Firestore document
  static CycleRecommendation fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return CycleRecommendation(
      id: doc.id,
      title: data['title'] ?? '',
      value: data['value'] ?? '',
      category: data['category'] ?? '',
      description: data['description'] ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      machineId: data['machineId'],
      userId: data['userId'],
      batchId: data['batchId'],
      
      // Drum Controller
      drumCycles: data['drumCycles'],
      drumDuration: data['drumDuration'],
      drumCompletedCycles: data['drumCompletedCycles'],
      drumStatus: data['drumStatus'],
      drumStartedAt: (data['drumStartedAt'] as Timestamp?)?.toDate(),
      drumCompletedAt: (data['drumCompletedAt'] as Timestamp?)?.toDate(),
      drumTotalRuntimeSeconds: data['drumTotalRuntimeSeconds'],
      
      // Aerator
      aeratorCycles: data['aeratorCycles'],
      aeratorDuration: data['aeratorDuration'],
      aeratorCompletedCycles: data['aeratorCompletedCycles'],
      aeratorStatus: data['aeratorStatus'],
      aeratorStartedAt: (data['aeratorStartedAt'] as Timestamp?)?.toDate(),
      aeratorCompletedAt: (data['aeratorCompletedAt'] as Timestamp?)?.toDate(),
      aeratorTotalRuntimeSeconds: data['aeratorTotalRuntimeSeconds'],
    );
  }

  /// Convert to Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'value': value,
      'category': category,
      'description': description,
      'timestamp': Timestamp.fromDate(timestamp),
      if (machineId != null) 'machineId': machineId,
      if (userId != null) 'userId': userId,
      if (batchId != null) 'batchId': batchId,
      
      // Drum Controller
      if (drumCycles != null) 'drumCycles': drumCycles,
      if (drumDuration != null) 'drumDuration': drumDuration,
      if (drumCompletedCycles != null) 'drumCompletedCycles': drumCompletedCycles,
      if (drumStatus != null) 'drumStatus': drumStatus,
      if (drumStartedAt != null) 'drumStartedAt': Timestamp.fromDate(drumStartedAt!),
      if (drumCompletedAt != null) 'drumCompletedAt': Timestamp.fromDate(drumCompletedAt!),
      if (drumTotalRuntimeSeconds != null) 'drumTotalRuntimeSeconds': drumTotalRuntimeSeconds,
      
      // Aerator
      if (aeratorCycles != null) 'aeratorCycles': aeratorCycles,
      if (aeratorDuration != null) 'aeratorDuration': aeratorDuration,
      if (aeratorCompletedCycles != null) 'aeratorCompletedCycles': aeratorCompletedCycles,
      if (aeratorStatus != null) 'aeratorStatus': aeratorStatus,
      if (aeratorStartedAt != null) 'aeratorStartedAt': Timestamp.fromDate(aeratorStartedAt!),
      if (aeratorCompletedAt != null) 'aeratorCompletedAt': Timestamp.fromDate(aeratorCompletedAt!),
      if (aeratorTotalRuntimeSeconds != null) 'aeratorTotalRuntimeSeconds': aeratorTotalRuntimeSeconds,
    };
  }

  // ===== DATA LOGIC HELPERS =====
  
  /// Check if this is a recommendation
  bool get isRecommendation => category.toLowerCase() == 'recoms';

  /// Check if this is a cycle
  bool get isCycle => category.toLowerCase() == 'cycles';
  
  /// Check if drum controller has been started
  bool get hasDrumController => drumCycles != null;
  
  /// Check if aerator has been started
  bool get hasAerator => aeratorCycles != null;
  
  /// Check if drum controller is running
  bool get isDrumRunning => drumStatus == 'running';
  
  /// Check if aerator is running
  bool get isAeratorRunning => aeratorStatus == 'running';
}