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
    String? batchName,
    String? startNotes, 
    DateTime? completedAt,
    double? finalWeight,
    String? completionNotes,
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
      batchName: data['batchName'],
      startNotes: data['startNotes'],
      completedAt: (data['completedAt'] as Timestamp?)?.toDate(),
      finalWeight: (data['finalWeight'] as num?)?.toDouble(),
      completionNotes: data['completionNotes'] as String?,
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
      if (batchName != null) 'batchName': batchName, 
      if (startNotes != null) 'startNotes': startNotes,
      if (completedAt != null) 'completedAt': Timestamp.fromDate(completedAt!),
      if (finalWeight != null) 'finalWeight': finalWeight,
      if (completionNotes != null) 'completionNotes': completionNotes,
    };
  }

  /// Get formatted batch name
  String get displayName => batchName ?? 'Batch #$batchNumber'; 
  
  /// Get completion progress percentage // temporary logic
  double getProgress({int totalDays = 12}) {
    if (!isActive && completedAt != null) return 100.0;
    final daysPassed = DateTime.now().difference(createdAt).inDays;
    return (daysPassed / totalDays * 100).clamp(0.0, 100.0);
  }
}