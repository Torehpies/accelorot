// lib/data/models/cycle_recommendation.dart

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'cycle_recommendation.freezed.dart';

/// Pure data model for cycles and recommendations
/// No UI concerns - just data
@freezed
abstract class CycleRecommendation with _$CycleRecommendation {
  const factory CycleRecommendation({
    required String id,
    required String title,
    required String value,
    required String category, // 'Recoms' or 'Cycles'
    required String description,
    required DateTime timestamp,
    String? machineId,
    String? userId,
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
      'machineId': machineId,
      'userId': userId,
    };
  }

  // ===== HELPERS =====

  /// Check if this is a recommendation
  bool get isRecommendation => category.toLowerCase() == 'recoms';

  /// Check if this is a cycle
  bool get isCycle => category.toLowerCase() == 'cycles';
}