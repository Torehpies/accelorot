// lib/frontend/operator/machine_management/models/machine_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class MachineModel {
  final String machineName;
  final String machineId;
  final String userId;
  final String teamId;
  final DateTime dateCreated;
  final bool isArchived;

  MachineModel({
    required this.machineName,
    required this.machineId,
    required this.userId,
    this.teamId = '',
    required this.dateCreated,
    this.isArchived = false,
  });

  // Convert model to Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      'machineName': machineName,
      'machineId': machineId,
      'userId': userId,
      'teamId': teamId,
      'dateCreated': Timestamp.fromDate(dateCreated),
      'isArchived': isArchived,
    };
  }

  // Create model from Firestore document
  factory MachineModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MachineModel(
      machineName: data['machineName'] ?? '',
      machineId: data['machineId'] ?? '',
      userId: data['userId'] ?? '',
      teamId: data['teamId'] ?? '',
      dateCreated: (data['dateCreated'] as Timestamp).toDate(),
      isArchived: data['isArchived'] ?? false,
    );
  }

  // Create model from mock data map
  factory MachineModel.fromMap(Map<String, dynamic> map) {
    return MachineModel(
      machineName: map['machineName'] ?? '',
      machineId: map['machineId'] ?? '',
      userId: map['userId'] ?? '',
      teamId: map['teamId'] ?? '',
      dateCreated: map['dateCreated'] ?? DateTime.now(),
      isArchived: map['isArchived'] ?? false,
    );
  }

  // Create a copy with modified fields
  MachineModel copyWith({
    String? machineName,
    String? machineId,
    String? userId,
    String? teamId,
    DateTime? dateCreated,
    bool? isArchived,
  }) {
    return MachineModel(
      machineName: machineName ?? this.machineName,
      machineId: machineId ?? this.machineId,
      userId: userId ?? this.userId,
      teamId: teamId ?? this.teamId,
      dateCreated: dateCreated ?? this.dateCreated,
      isArchived: isArchived ?? this.isArchived,
    );
  }
}
