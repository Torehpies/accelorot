import 'package:flutter_application_1/utils/timestamp_converter.dart';
import 'package:flutter_application_1/utils/user_status.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
abstract class User with _$User {
  const factory User({
    required String uid,
    required String email,
    required String firstname,
    required String lastname,
    required String globalRole,
    String? teamRole,
    @Default('') String teamId,
    @Default(UserStatus.unverified) UserStatus status,
    @TimestampConverter() required DateTime createdAt,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}
