import 'package:flutter_application_1/data/services/api/model/team_member/team_member.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'team_members_state.freezed.dart';
part 'team_members_state.g.dart';

@freezed
abstract class TeamMembersState with _$TeamMembersState {
  const factory TeamMembersState({
    @Default(<TeamMember>[]) List<TeamMember> members,
    @Default(0) int currentPage, // 0-based
    @Default(10) int pageSize,
    @Default(false) bool isLoading,
    @Default(true) bool hasNextPage,
  }) = _TeamMembersState;

  factory TeamMembersState.fromJson(Map<String, dynamic> json) =>
      _$TeamMembersStateFromJson(json);
}
