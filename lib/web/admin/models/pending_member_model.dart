// lib/models/pending_member_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class PendingMemberModel {
  final String id;
  final String requestorId;
  final String name;
  final String email;
  final DateTime? requestedAt;

  PendingMemberModel({
    required this.id,
    required this.requestorId,
    required this.name,
    required this.email,
    this.requestedAt,
  });

  factory PendingMemberModel.fromFirestore(
    String docId,
    Map<String, dynamic> data,
    Map<String, dynamic>? userData,
  ) {
    final firstName = userData?['firstname'] ?? '';
    final lastName = userData?['lastname'] ?? '';
    final name = '$firstName $lastName'.trim();

    return PendingMemberModel(
      id: docId,
      requestorId: data['requestorId'] ?? '',
      name: name.isNotEmpty ? name : 'Unknown',
      email: data['requestorEmail'] ?? userData?['email'] ?? '',
      requestedAt: (data['requestedAt'] as Timestamp?)?.toDate(),
    );
  }

  String formatDate() {
    if (requestedAt == null) return 'Unknown';
    final date = requestedAt!;
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'requestorId': requestorId,
      'name': name,
      'email': email,
      'date': formatDate(),
    };
  }
}
