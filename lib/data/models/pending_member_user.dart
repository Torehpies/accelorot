import 'package:freezed_annotation/freezed_annotation.dart';

part 'pending_member_user.freezed.dart';
part 'pending_member_user.g.dart';

@freezed
abstract class PendingMemberUser with _$PendingMemberUser {
  const factory PendingMemberUser({
    required String uid,
    required String firstName,
    required String lastName,
    required String email,
  }) = _PendingMemberUser;

  factory PendingMemberUser.fromJson(Map<String, dynamic> json) =>
      _$PendingMemberUserFromJson(json);
}
