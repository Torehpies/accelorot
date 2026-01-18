import 'package:flutter_application_1/data/services/api/model/team_member/team_member.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'team_members_state.freezed.dart';

@freezed
abstract class TeamMembersState with _$TeamMembersState {
  const factory TeamMembersState({
		// Cumulative members for infinite scrolling
    @Default(<TeamMember>[]) List<TeamMember> items,
    @Default(<TeamMember>[]) List<TeamMember> members,
    @Default({}) Map<int, List<TeamMember>> pagesByIndex,
    @Default(0) int currentPage,
    @Default(10) int pageSize,
    @Default(false) bool isLoading,
    @Default(true) bool hasNextPage,
		DateTime? lastFetchedAt,
  }) = _TeamMembersState;
}
