import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
abstract class User with _$User {
  const factory User({
    required String uid,
    required String email,
    required String firstName,
    required String lastName,
    required String globalRole,
		required String teamRole,
		required String teamId,
    @Default(true) bool isActive,
    required bool emailVerified,
    required DateTime createdAt,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}
