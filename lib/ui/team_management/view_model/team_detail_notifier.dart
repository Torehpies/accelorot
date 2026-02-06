import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/utils/roles.dart';
import 'package:flutter_application_1/data/services/firebase/firebase_team_member_service.dart';
import 'package:flutter_application_1/data/services/api/model/team_member/team_member.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'team_detail_notifier.freezed.dart';
part 'team_detail_notifier.g.dart';

@freezed
abstract class TeamDetailState with _$TeamDetailState {
  const factory TeamDetailState({
    @Default([]) List<TeamMember> admins,
    @Default([]) List<TeamMember> members,
    @Default(false) bool isLoading,
    @Default(false) bool hasNextPage,
    String? errorMessage,
  }) = _TeamDetailState;
}

@riverpod
class TeamDetailNotifier extends _$TeamDetailNotifier {
  late final FirebaseTeamMemberService _service;

  @override
  TeamDetailState build(String teamId) {
    _service = FirebaseTeamMemberService(FirebaseFirestore.instance);
    fetchInitialTeamMembers(teamId);
    return const TeamDetailState(isLoading: true);
  }

  Future<void> fetchInitialTeamMembers(String teamId) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      final members = await _service.fetchTeamMembersPage(
        teamId: teamId,
        pageSize: 20,
        pageIndex: 0,
      );
      state = state.copyWith(
        admins: members.where((m) => m.teamRole == TeamRole.admin).toList(),
        members: members.where((m) => m.teamRole != TeamRole.admin).toList(),
        isLoading: false,
        hasNextPage: members.length == 20, // Assuming 20 is the page size.
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Error loading team members: ${e.toString()}',
      );
    }
  }

  Future<void> loadNextPage(String teamId) async {
    if (!state.hasNextPage || state.isLoading) return;
    try {
      state = state.copyWith(isLoading: true);
      final nextPageIndex = (state.members.length + state.admins.length) ~/ 20;
      final members = await _service.fetchTeamMembersPage(
        teamId: teamId,
        pageSize: 20,
        pageIndex: nextPageIndex,
      );
      state = state.copyWith(
        admins: [
          ...state.admins,
          ...members.where((m) => m.teamRole == TeamRole.admin),
        ],
        members: [
          ...state.members,
          ...members.where((m) => m.teamRole != TeamRole.admin),
        ],
        isLoading: false,
        hasNextPage: members.length == 20,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Error loading more members: ${e.toString()}',
      );
    }
  }
}
