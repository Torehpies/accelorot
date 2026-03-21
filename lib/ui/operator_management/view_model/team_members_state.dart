// lib/ui/operator_management/view_model/team_members_state.dart

import 'package:flutter_application_1/data/services/api/model/team_member/team_member.dart';
import 'package:flutter_application_1/ui/activity_logs/models/activity_common.dart';
import 'package:flutter_application_1/ui/operator_management/models/team_member_filters.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'team_members_state.freezed.dart';

@freezed
abstract class TeamMembersState with _$TeamMembersState {
  const factory TeamMembersState({
    @Default(<TeamMember>[]) List<TeamMember> allMembers,
    @Default(<TeamMember>[]) List<TeamMember> filteredMembers,
    @Default(0) int currentPage,
    @Default(10) int itemsPerPage,
    @Default(15) int displayLimit,
    @Default(false) bool isLoading,
    @Default(DateFilterRange(type: DateFilterType.none))
    DateFilterRange dateFilter,
    @Default('') String searchQuery,
    String? sortColumn,
    @Default(true) bool sortAscending,
    @Default(TeamMemberStatusFilter.all) TeamMemberStatusFilter statusFilter,
  }) = _TeamMembersState;

  const TeamMembersState._();

  // ===== WEB COMPUTED =====

  List<TeamMember> get paginatedMembers {
    final start = currentPage * itemsPerPage;
    final end = start + itemsPerPage;
    if (start >= filteredMembers.length) return [];
    return filteredMembers.sublist(
      start,
      end > filteredMembers.length ? filteredMembers.length : end,
    );
  }

  int get totalPages {
    if (filteredMembers.isEmpty) return 1;
    return (filteredMembers.length / itemsPerPage).ceil();
  }

  // ===== MOBILE COMPUTED =====

  List<TeamMember> get displayedMembers {
    if (filteredMembers.length <= displayLimit) return filteredMembers;
    return filteredMembers.sublist(0, displayLimit);
  }
  bool get hasMoreToLoad => filteredMembers.length > displayLimit;
  int get remainingCount => filteredMembers.length - displayLimit;
  bool get hasActiveFilters {
    return statusFilter != TeamMemberStatusFilter.all ||
        dateFilter.isActive ||
        searchQuery.isNotEmpty;
  }
}