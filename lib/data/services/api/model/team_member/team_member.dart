import 'package:flutter_application_1/utils/roles.dart';
import 'package:flutter_application_1/utils/timestamp_converter.dart';
import 'package:flutter_application_1/utils/user_status.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'team_member.freezed.dart';
part 'team_member.g.dart';

@freezed
abstract class TeamMember with _$TeamMember {
  const factory TeamMember({
    required String id,
    required String email,
    @Default('') String firstName,
    @Default('') String lastName,
    @Default(TeamRole.operator) TeamRole teamRole,
    @Default(UserStatus.active) UserStatus status,
    @TimestampConverter() required DateTime addedAt,
  }) = _TeamMember;

  factory TeamMember.fromJson(Map<String, dynamic> json) =>
      _$TeamMemberFromJson(json);
}
