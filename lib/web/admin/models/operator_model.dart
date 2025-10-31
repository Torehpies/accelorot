// lib/models/operator_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class OperatorModel {
  final String id;
  final String uid;
  final String name;
  final String email;
  final String role;
  final bool isArchived;
  final bool hasLeft;
  final DateTime? archivedAt;
  final DateTime? leftAt;
  final DateTime? addedAt;

  OperatorModel({
    required this.id,
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    required this.isArchived,
    required this.hasLeft,
    this.archivedAt,
    this.leftAt,
    this.addedAt,
  });

  factory OperatorModel.fromFirestore(String userId, Map<String, dynamic> memberData, Map<String, dynamic>? userData) {
    final firstName = userData?['firstname'] ?? '';
    final lastName = userData?['lastname'] ?? '';
    final name = '$firstName $lastName'.trim();

    return OperatorModel(
      id: userId,
      uid: userId,
      name: name.isNotEmpty ? name : memberData['name'] ?? 'Unknown',
      email: memberData['email'] ?? userData?['email'] ?? '',
      role: memberData['role'] ?? userData?['role'] ?? 'Operator',
      isArchived: memberData['isArchived'] ?? false,
      hasLeft: memberData['hasLeft'] ?? false,
      archivedAt: (memberData['archivedAt'] as Timestamp?)?.toDate(),
      leftAt: (memberData['leftAt'] as Timestamp?)?.toDate(),
      addedAt: (memberData['addedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'uid': uid,
      'name': name,
      'email': email,
      'role': role,
      'isArchived': isArchived,
      'hasLeft': hasLeft,
      'archivedAt': archivedAt,
      'leftAt': leftAt,
      'dateAdded': formatDate(addedAt),
    };
  }

  String formatDate(DateTime? date) {
    if (date == null) return 'Unknown';
    return '${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}-${date.year}';
  }

  OperatorModel copyWith({
    String? id,
    String? uid,
    String? name,
    String? email,
    String? role,
    bool? isArchived,
    bool? hasLeft,
    DateTime? archivedAt,
    DateTime? leftAt,
    DateTime? addedAt,
  }) {
    return OperatorModel(
      id: id ?? this.id,
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      isArchived: isArchived ?? this.isArchived,
      hasLeft: hasLeft ?? this.hasLeft,
      archivedAt: archivedAt ?? this.archivedAt,
      leftAt: leftAt ?? this.leftAt,
      addedAt: addedAt ?? this.addedAt,
    );
  }
}
