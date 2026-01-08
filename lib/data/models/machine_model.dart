import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'machine_model.freezed.dart';
part 'machine_model.g.dart';

enum MachineStatus {
  @JsonValue('Active')
  active,
  @JsonValue('Inactive')
  inactive,
  @JsonValue('Under Maintenance')
  underMaintenance,
}

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
    @Default(MachineStatus.active) MachineStatus status,
    @Default([]) List<String> assignedUserIds,
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
    
    // Parse status
    MachineStatus status = MachineStatus.active;
    if (data['status'] != null) {
      final statusStr = data['status'] as String;
      status = MachineStatus.values.firstWhere(
        (e) => e.toString().split('.').last == statusStr.toLowerCase() ||
               statusStr == 'Active' && e == MachineStatus.active ||
               statusStr == 'Inactive' && e == MachineStatus.inactive ||
               statusStr == 'Under Maintenance' && e == MachineStatus.underMaintenance,
        orElse: () => MachineStatus.active,
      );
    }
    
    return MachineModel(
      id: docId,
      machineId: machineIdFromData,
      machineName: data['machineName'] ?? '',
      userId: data['userId'] as String?,
      teamId: data['teamId'] ?? '',
      dateCreated: (data['dateCreated'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isArchived: data['isArchived'] ?? false,
      status: status,
      assignedUserIds: (data['assignedUserIds'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      lastModified: (data['lastModified'] as Timestamp?)?.toDate(),
      currentBatchId: data['currentBatchId'] as String?,
      metadata: (data['metadata'] as Map<String, dynamic>?) ?? <String, dynamic>{},
    );
  }
  
  // Helper to convert to Firestore
  Map<String, dynamic> toFirestore() {
    String statusValue;
    switch (status) {
      case MachineStatus.active:
        statusValue = 'Active';
        break;
      case MachineStatus.inactive:
        statusValue = 'Inactive';
        break;
      case MachineStatus.underMaintenance:
        statusValue = 'Under Maintenance';
        break;
    }
    
    return {
      'machineId': machineId,
      'machineName': machineName,
      if (userId != null) 'userId': userId,
      'teamId': teamId,
      'dateCreated': Timestamp.fromDate(dateCreated),
      'isArchived': isArchived,
      'status': statusValue,
      'assignedUserIds': assignedUserIds,
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
    @Default([]) List<String> assignedUserIds,
    @Default(MachineStatus.active) MachineStatus status,
  }) = _CreateMachineRequest;
  
  factory CreateMachineRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateMachineRequestFromJson(json);
}

@freezed
abstract class UpdateMachineRequest with _$UpdateMachineRequest {
  const factory UpdateMachineRequest({
    required String machineId,
    String? machineName,
    MachineStatus? status,
    List<String>? assignedUserIds,
    String? currentBatchId,
    Map<String, dynamic>? metadata,
  }) = _UpdateMachineRequest;
  
  factory UpdateMachineRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateMachineRequestFromJson(json);
}