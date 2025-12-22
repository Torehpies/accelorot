import 'package:flutter_application_1/data/providers/auth_providers.dart';
import 'package:flutter_application_1/data/providers/team_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'team_members_state.dart';

part 'team_members_notifier.g.dart';

@riverpod
class TeamMembersNotifier extends _$TeamMembersNotifier {
  @override
  TeamMembersState build() {
    state = const TeamMembersState();
    Future.microtask(() => _loadPage(0));
    return state;
  }

  Future<void> _loadPage(int pageIndex) async {
    if (state.isLoading) return;

    final teamUser = ref.watch(appUserProvider).value;
    final teamId = teamUser?.teamId;
    if (teamId == null || teamId.isEmpty) {

      state = state.copyWith(
        members: const [],
        currentPage: 0,
        isLoading: false,
        hasNextPage: false,
      );
      return;
    }

    state = state.copyWith(isLoading: true);

    final service = ref.read(teamMemberServiceProvider);

    final members = await service.fetchTeamMembersPage(
      teamId: teamId,
      pageSize: state.pageSize,
      pageIndex: pageIndex,
    );

    state = state.copyWith(
      members: members,
      currentPage: pageIndex,
      isLoading: false,
      hasNextPage: members.length == state.pageSize,
    );
  }

  Future<void> goToPage(int pageIndex) => _loadPage(pageIndex);

  Future<void> nextPage() async {
    if (!state.hasNextPage) return;
    await _loadPage(state.currentPage + 1);
  }

  Future<void> previousPage() async {
    if (state.currentPage == 0) return;
    await _loadPage(state.currentPage - 1);
  }

  Future<void> refresh() => _loadPage(state.currentPage);
}
