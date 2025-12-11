// machine_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

/// Model representing a machine
class MachineModel {
  final String id; // Document ID
  final String machineId;
  final String machineName;
  final String userId; // Operator/user who owns/operates it
  final String teamId; // Team it belongs to
  final bool isArchived;
  final DateTime dateCreated;

  MachineModel({
    required this.id,
    required this.machineId,
    required this.machineName,
    required this.userId,
    required this.teamId,
    required this.isArchived,
    required this.dateCreated,
  });

  /// Create machine from Firestore document
  factory MachineModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MachineModel(
      id: doc.id,
      machineId: data['machineId'] ?? '',
      machineName: data['machineName'] ?? 'Unknown Machine',
      userId: data['userId'] ?? '',
      teamId: data['teamId'] ?? '',
      isArchived: data['isArchived'] ?? false,
      dateCreated:
          (data['dateCreated'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Convert to map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'machineId': machineId,
      'machineName': machineName,
      'userId': userId,
      'teamId': teamId,
      'isArchived': isArchived,
      'dateCreated': Timestamp.fromDate(dateCreated),
    };
  }

  /// Create a copy with modified fields
  MachineModel copyWith({
    String? id,
    String? machineId,
    String? machineName,
    String? userId,
    String? teamId,
    bool? isArchived,
    DateTime? dateCreated,
  }) {
    return MachineModel(
      id: id ?? this.id,
      machineId: machineId ?? this.machineId,
      machineName: machineName ?? this.machineName,
      userId: userId ?? this.userId,
      teamId: teamId ?? this.teamId,
      isArchived: isArchived ?? this.isArchived,
      dateCreated: dateCreated ?? this.dateCreated,
    );
  }
}
