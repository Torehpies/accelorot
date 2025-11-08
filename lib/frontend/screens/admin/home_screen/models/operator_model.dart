// operator_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

/// Model representing an operator (team member with role "Operator")
class OperatorModel {
  final String userId;
  final String name;
  final String email;
  final String role;
  final bool isArchived;
  final DateTime addedAt;

  OperatorModel({
    required this.userId,
    required this.name,
    required this.email,
    required this.role,
    required this.isArchived,
    required this.addedAt,
  });

  /// Create operator from Firestore document
  factory OperatorModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return OperatorModel(
      userId: doc.id,
      name: data['name'] ?? 'Unknown',
      email: data['email'] ?? '',
      role: data['role'] ?? 'Operator',
      isArchived: data['isArchived'] ?? false,
      addedAt: (data['addedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Convert to map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'email': email,
      'role': role,
      'isArchived': isArchived,
      'addedAt': Timestamp.fromDate(addedAt),
    };
  }

  /// Create a copy with modified fields
  OperatorModel copyWith({
    String? userId,
    String? name,
    String? email,
    String? role,
    bool? isArchived,
    DateTime? addedAt,
  }) {
    return OperatorModel(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      isArchived: isArchived ?? this.isArchived,
      addedAt: addedAt ?? this.addedAt,
    );
  }
}