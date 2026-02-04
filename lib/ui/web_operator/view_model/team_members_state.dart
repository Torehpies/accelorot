// lib/ui/web_operator/models/team_members_state.dart

import 'package:flutter_application_1/data/services/api/model/team_member/team_member.dart';
import 'package:flutter_application_1/ui/activity_logs/models/activity_common.dart';
import 'package:flutter_application_1/ui/web_operator/models/team_member_filters.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'team_members_state.freezed.dart';

@freezed
abstract class TeamMembersState with _$TeamMembersState {
  const factory TeamMembersState({
    // Cumulative members for infinite scrolling
    @Default(<TeamMember>[]) List<TeamMember> items,
    @Default(<TeamMember>[]) List<TeamMember> members,
    @Default(<TeamMember>[]) List<TeamMember> filteredMembers,
    @Default({}) Map<int, List<TeamMember>> pagesByIndex,
    @Default(0) int currentPage,
    @Default(10) int pageSize,
    @Default(false) bool isLoading,
    @Default(true) bool hasNextPage,
    DateTime? lastFetchedAt,
    @Default(DateFilterRange(type: DateFilterType.none))
    DateFilterRange dateFilter,
    @Default('') String searchQuery,
    String? sortColumn,
    @Default(true) bool sortAscending,
    @Default(TeamMemberStatusFilter.all) TeamMemberStatusFilter statusFilter,
  }) = _TeamMembersState;
}