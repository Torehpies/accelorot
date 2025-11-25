import 'package:flutter_application_1/utils/user_status.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

//String _userStatusToJson(UserStatus status) => status.value;
//UserStatus _userStatusFromJson(String statusValue) {
//  return UserStatus.values.firstWhere(
//    (e) => e.value == statusValue,
//    orElse: () => UserStatus.unverified,
//  );
//}

@freezed
abstract class User with _$User {
  const factory User({
    required String uid,
    required String email,
    required String firstName,
    required String lastName,
    required String globalRole,
    required String teamRole,
    @Default('') String teamId,
    @Default(UserStatus.unverified) UserStatus status,
    required DateTime createdAt,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}
