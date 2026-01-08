import 'package:flutter_application_1/data/providers/auth_providers.dart';
import 'package:flutter_application_1/data/providers/team_providers.dart';
import 'package:flutter_application_1/data/services/api/model/pending_member/pending_member.dart';
import 'package:flutter_application_1/data/utils/result.dart';
import 'package:flutter_application_1/ui/web_operator/view_model/pending_members_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'pending_members_notifier.g.dart';

@riverpod
class PendingMembersNotifier extends _$PendingMembersNotifier {
  @override
  PendingMembersState build() {
		state = const PendingMembersState();
    Future.microtask(() => _loadPage(0));
    return state;
  }

  static const _cacheTtl = Duration(minutes: 1);

  bool _isCacheFresh(DateTime? lastFetchedAt) {
    if (lastFetchedAt == null) return false;
    return DateTime.now().difference(lastFetchedAt) < _cacheTtl;
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

    final cachedPage = state.pagesByIndex[pageIndex];
    if (cachedPage != null && _isCacheFresh(state.lastFetchedAt)) {
      state = state.copyWith(
        currentPage: pageIndex,
        members: cachedPage,
        isLoading: false,
      );
      return;
    }
    state = state.copyWith(isLoading: true);

    final service = ref.read(pendingMembersServiceProvider);

    final result = await service.getPendingMembersPage(
      teamId: teamId,
      pageSize: state.pageSize,
      pageIndex: pageIndex,
    );

    return switch (result) {
      Ok<List<PendingMember>>() => _handleSuccess(pageIndex, result.value),
      Error<List<PendingMember>>() => _handleError(result.error),
    };
  }

  void _handleSuccess(int pageIndex, List<PendingMember> members) {
    final updatedPages = Map<int, List<PendingMember>>.from(state.pagesByIndex)
      ..[pageIndex] = members;

    state = state.copyWith(
      members: members,
      currentPage: pageIndex,
      isLoading: false,
      isError: false,
      error: null,
      hasNextPage: members.length == state.pageSize,
      pagesByIndex: updatedPages,
      lastFetchedAt: DateTime.now(),
    );
  }

  void _handleError(Exception error) {
    state = state.copyWith(
      isLoading: false,
      isError: true,
      error: error,
      members: [], // Or keep previous members
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

  Future<void> refresh() async {
    final updatedPages = Map<int, List<PendingMember>>.from(state.pagesByIndex)
      ..remove(state.currentPage);
    state = state.copyWith(pagesByIndex: updatedPages, lastFetchedAt: null);
    await _loadPage(state.currentPage);
  }

  // Future<void> updateOperator(EditOperatorForm form) async {
  //   state = state.copyWith(isLoading: true);
  //   try {
  //     final teamUser = ref.read(appUserProvider).value;
  //     final teamId = teamUser?.teamId;
  //     if (teamId == null) return;
  //
  //     final currentMembers = state.pagesByIndex[state.currentPage] ?? [];
  //     final updatedMembers = currentMembers.map((m) {
  //       if (m.id == form.id) {
  //         return m.copyWith(
  //           email: form.email,
  //           firstName: form.firstName,
  //           lastName: form.lastName,
  //           status: form.status,
  //         );
  //       }
  //       return m;
  //     }).toList();
  //
  //     final updatedPages = Map<int, List<TeamMember>>.from(state.pagesByIndex)
  //       ..[state.currentPage] = updatedMembers;
  //
  //     state = state.copyWith(
  //       pagesByIndex: updatedPages,
  //       members: updatedMembers,
  //       lastFetchedAt: DateTime.now(),
  //     );
  //
  //     final member = TeamMember(
  //       id: form.id,
  //       email: form.email,
  //       firstName: form.firstName,
  //       lastName: form.lastName,
  //       status: form.status,
  //       addedAt: DateTime.now(),
  //     );
  //
  //     await ref
  //         .read(teamMemberServiceProvider)
  //         .updateTeamMember(member: member, teamId: teamId);
  //
  //     await ref.read(appUserServiceProvider).updateUserField(form.id, {
  //       'status': form.status.value,
  //     });
  //
  //   } catch (e) {
  //     await refresh();
  //   } finally {
  //     state = state.copyWith(isLoading: false);
  //   }
  // }
}
