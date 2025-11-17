import 'package:flutter_application_1/data/models/user.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'team_member.freezed.dart';
part 'team_member.g.dart';

@freezed
abstract class TeamMember with _$TeamMember {
  const factory TeamMember({
    required User user,
		required String teamId,
		required String teamRole,
    required DateTime addedAt,
    @Default(false) bool isArchived,
  }) = _TeamMember;

  factory TeamMember.fromJson(Map<String, dynamic> json) =>
      _$TeamMemberFromJson(json);
}
