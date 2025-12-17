import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'machine_model.freezed.dart';
part 'machine_model.g.dart';

@freezed
abstract class MachineModel with _$MachineModel {
  const MachineModel._(); // Private constructor for custom methods

  const factory MachineModel({
    String? id, 
    required String machineId,
    required String machineName,
    String? userId, 
    required String teamId,
    required DateTime dateCreated,
    @Default(false) bool isArchived,
    DateTime? lastModified,
    String? currentBatchId,
    Map<String, dynamic>? metadata,
  }) = _MachineModel;

  factory MachineModel.fromJson(Map<String, dynamic> json) =>
      _$MachineModelFromJson(json);

  // Factory for Firestore documents
  factory MachineModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? <String, dynamic>{};
    final docId = doc.id;
    final machineIdFromData = (data['machineId'] as String?) ?? docId;
    return MachineModel(
      id: docId,
      machineId: machineIdFromData,
      machineName: data['machineName'] ?? '',
      userId: data['userId'] as String?,
      teamId: data['teamId'] ?? '',
      dateCreated: (data['dateCreated'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isArchived: data['isArchived'] ?? false,
      lastModified: (data['lastModified'] as Timestamp?)?.toDate(),
      currentBatchId: data['currentBatchId'] as String?,
      metadata: (data['metadata'] as Map<String, dynamic>?) ?? <String, dynamic>{},
    );
  }
  
  // Helper to convert to Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'machineId': machineId,
      'machineName': machineName,
      if (userId != null) 'userId': userId,
      'teamId': teamId,
      'dateCreated': Timestamp.fromDate(dateCreated),
      'isArchived': isArchived,
      if (lastModified != null) 'lastModified': Timestamp.fromDate(lastModified!),
      if (currentBatchId != null) 'currentBatchId': currentBatchId,
      if (metadata != null) 'metadata': metadata,
    };
  }
}

// Request models for mutations
@freezed
abstract class CreateMachineRequest with _$CreateMachineRequest {
  const factory CreateMachineRequest({
    required String machineId,
    required String machineName,
    required String teamId,
  }) = _CreateMachineRequest;
  
  factory CreateMachineRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateMachineRequestFromJson(json);
}

@freezed
abstract class UpdateMachineRequest with _$UpdateMachineRequest {
  const factory UpdateMachineRequest({
    required String machineId,
    String? machineName,
    String? currentBatchId,
    Map<String, dynamic>? metadata,
  }) = _UpdateMachineRequest;
  
  factory UpdateMachineRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateMachineRequestFromJson(json);
}