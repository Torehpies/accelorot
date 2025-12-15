import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'batch_model.freezed.dart';
part 'batch_model.g.dart';

@freezed
abstract class BatchModel with _$BatchModel {
  const BatchModel._();

  const factory BatchModel({
    required String id,
    required String machineId,
    required String userId,
    required int batchNumber,
    required bool isActive,
    required DateTime createdAt,
    required DateTime updatedAt,
    String? teamId,
  }) = _BatchModel;

  factory BatchModel.fromJson(Map<String, dynamic> json) =>
      _$BatchModelFromJson(json);

  /// Create from Firestore document
  factory BatchModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    
    return BatchModel(
      id: doc.id,
      machineId: data['machineId'] ?? '',
      userId: data['userId'] ?? '',
      batchNumber: data['batchNumber'] ?? 0,
      isActive: data['isActive'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      teamId: data['teamId'],
    );
  }

  /// Convert to Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      'machineId': machineId,
      'userId': userId,
      'batchNumber': batchNumber,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      if (teamId != null) 'teamId': teamId,
    };
  }

  /// Get formatted batch name
  String get displayName => 'Batch #$batchNumber';
}