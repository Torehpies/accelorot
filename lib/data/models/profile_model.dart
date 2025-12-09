import 'package:cloud_firestore/cloud_firestore.dart';
import 'operator_model.dart';

class ProfileModel {
  final String uid;
  final String email;
  final String firstName;
  final String lastName;
  final String role;
  final String? teamId;
  final DateTime? lastLogin;
  final bool isActive;
  final bool emailVerified;

  ProfileModel({
    required this.uid,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.role,
    this.teamId,
    this.lastLogin,
    this.isActive = true,
    this.emailVerified = true,
  });

  /// Create ProfileModel from Firestore user document
  factory ProfileModel.fromFirestore(
    String uid,
    Map<String, dynamic> data,
  ) {
    return ProfileModel(
      uid: uid,
      email: data['email'] ?? '',
      firstName: data['firstname'] ?? '',
      lastName: data['lastname'] ?? '',
      role: data['role'] ?? 'User',
      teamId: data['teamId'],
      lastLogin: (data['lastLogin'] as Timestamp?)?.toDate(),
      isActive: data['isActive'] ?? true,
      emailVerified: data['emailVerified'] ?? true,
    );
  }

  /// Convert from OperatorModel (useful when viewing team member profiles)
  factory ProfileModel.fromOperator(OperatorModel operator) {
    final nameParts = operator.name.split(' ');
    final firstName = nameParts.isNotEmpty ? nameParts.first : '';
    final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

    return ProfileModel(
      uid: operator.uid,
      email: operator.email,
      firstName: firstName,
      lastName: lastName,
      role: operator.role,
      isActive: !operator.isArchived && !operator.hasLeft,
      emailVerified: true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'firstname': firstName,
      'lastname': lastName,
      'role': role,
      if (teamId != null) 'teamId': teamId,
      if (lastLogin != null) 'lastLogin': Timestamp.fromDate(lastLogin!),
      'isActive': isActive,
      'emailVerified': emailVerified,
    };
  }

  Map<String, dynamic> toUpdateMap() {
    return {
      'firstname': firstName,
      'lastname': lastName,
    };
  }

  String get displayName => '$firstName $lastName'.trim();
  
  String get initials {
    final first = firstName.isNotEmpty ? firstName[0] : '';
    final last = lastName.isNotEmpty ? lastName[0] : '';
    return (first + last).toUpperCase();
  }

  ProfileModel copyWith({
    String? uid,
    String? email,
    String? firstName,
    String? lastName,
    String? role,
    String? teamId,
    DateTime? lastLogin,
    bool? isActive,
    bool? emailVerified,
  }) {
    return ProfileModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      role: role ?? this.role,
      teamId: teamId ?? this.teamId,
      lastLogin: lastLogin ?? this.lastLogin,
      isActive: isActive ?? this.isActive,
      emailVerified: emailVerified ?? this.emailVerified,
    );
  }
}