import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
//import 'operator_model.dart';

part 'profile_model.freezed.dart';
part 'profile_model.g.dart';

@freezed
abstract class ProfileModel with _$ProfileModel {
  const ProfileModel._();

  const factory ProfileModel({
    required String uid,
    required String email,
    required String firstName,
    required String lastName,
    required String role,
    String? teamId,
    @TimestampConverter() DateTime? lastLogin,
    @Default(true) bool isActive,
    @Default(true) bool emailVerified,
  }) = _ProfileModel;

  factory ProfileModel.fromJson(Map<String, dynamic> json) =>
      _$ProfileModelFromJson(json);

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
}

class TimestampConverter implements JsonConverter<DateTime?, Object?> {
  const TimestampConverter();

  @override
  DateTime? fromJson(Object? json) {
    if (json is Timestamp) {
      return json.toDate();
    }
    return null;
  }

  @override
  Object? toJson(DateTime? object) {
    return object != null ? Timestamp.fromDate(object) : null;
  }
}