// lib/data/models/machine_model.dart
// Keep your existing MachineModel - only add filter enum extension

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

// Machine status filter enum for table header dropdown
enum MachineStatusFilter {
  all,
  active,
  inactive,
  underMaintenance;

  String get displayName {
    switch (this) {
      case MachineStatusFilter.all:
        return 'All';
      case MachineStatusFilter.active:
        return 'Active';
      case MachineStatusFilter.inactive:
        return 'Archived';
      case MachineStatusFilter.underMaintenance:
        return 'Suspended';
    }
  }

  // Convert filter to actual status (null if 'all')
  MachineStatus? toStatus() {
    switch (this) {
      case MachineStatusFilter.all:
        return null;
      case MachineStatusFilter.active:
        return MachineStatus.active;
      case MachineStatusFilter.inactive:
        return MachineStatus.inactive;
      case MachineStatusFilter.underMaintenance:
        return MachineStatus.underMaintenance;
    }
  }

  // Create filter from status
  static MachineStatusFilter fromStatus(MachineStatus? status) {
    if (status == null) return MachineStatusFilter.all;
    switch (status) {
      case MachineStatus.active:
        return MachineStatusFilter.active;
      case MachineStatus.inactive:
        return MachineStatusFilter.inactive;
      case MachineStatus.underMaintenance:
        return MachineStatusFilter.underMaintenance;
    }
  }
}

@freezed
abstract class MachineModel with _$MachineModel {
  const MachineModel._();

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
    @Default(false) bool drumActive,
    @Default(false) bool aeratorActive,
    @Default(false) bool drumPaused,
    @Default(false) bool aeratorPaused,
  }) = _MachineModel;

  factory MachineModel.fromJson(Map<String, dynamic> json) =>
      _$MachineModelFromJson(json);

  factory MachineModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? <String, dynamic>{};
    final docId = doc.id;
    final machineIdFromData = (data['machineId'] as String?) ?? docId;

    MachineStatus status = MachineStatus.active;
    if (data['status'] != null) {
      final statusStr = data['status'] as String;
      status = MachineStatus.values.firstWhere(
        (e) =>
            e.toString().split('.').last == statusStr.toLowerCase() ||
            statusStr == 'Active' && e == MachineStatus.active ||
            statusStr == 'Inactive' && e == MachineStatus.inactive ||
            statusStr == 'Under Maintenance' &&
                e == MachineStatus.underMaintenance,
        orElse: () => MachineStatus.active,
      );
    }

    return MachineModel(
      id: docId,
      machineId: machineIdFromData,
      machineName: data['machineName'] ?? '',
      userId: data['userId'] as String?,
      teamId: data['teamId'] ?? '',
      dateCreated:
          (data['dateCreated'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isArchived: data['isArchived'] ?? false,
      status: status,
      assignedUserIds:
          (data['assignedUserIds'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      lastModified: (data['lastModified'] as Timestamp?)?.toDate(),
      currentBatchId: data['currentBatchId'] as String?,
      metadata:
          (data['metadata'] as Map<String, dynamic>?) ?? <String, dynamic>{},
      drumActive: data['drumActive'] ?? false,
      aeratorActive: data['aeratorActive'] ?? false,
      drumPaused: data['drumPaused'] ?? false,
      aeratorPaused: data['aeratorPaused'] ?? false,
    );
  }

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
      if (lastModified != null)
        'lastModified': Timestamp.fromDate(lastModified!),
      if (currentBatchId != null) 'currentBatchId': currentBatchId,
      if (metadata != null) 'metadata': metadata,
      'drumActive': drumActive,
      'aeratorActive': aeratorActive,
      'drumPaused': drumPaused,
      'aeratorPaused': aeratorPaused,
    };
  }
}

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
