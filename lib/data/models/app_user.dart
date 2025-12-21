import 'package:flutter_application_1/utils/timestamp_converter.dart';
import 'package:flutter_application_1/utils/user_status.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_user.freezed.dart';
part 'app_user.g.dart';

@freezed
abstract class AppUser with _$AppUser {
  const factory AppUser({
    required String uid,
    required String email,
    required String firstname,
    required String lastname,
    required String globalRole,
    String? teamRole,
    String? teamId,
    String? requestTeamId,
    @Default(UserStatus.unverified) UserStatus status,
    @TimestampConverter() required DateTime createdAt,
  }) = _AppUser;

  factory AppUser.fromJson(Map<String, dynamic> json) =>
      _$AppUserFromJson(json);
}
