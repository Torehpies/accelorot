import 'package:flutter_application_1/data/providers/app_user_providers.dart';
import 'package:flutter_application_1/data/providers/auth_providers.dart';
import 'package:flutter_application_1/data/providers/team_providers.dart';
import 'package:flutter_application_1/data/services/api/model/team_member/team_member.dart';
import 'package:flutter_application_1/ui/activity_logs/models/activity_common.dart';
import 'package:flutter_application_1/ui/web_operator/widgets/edit_operator_dialog.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'team_members_state.dart';

part 'team_members_notifier.g.dart';

@riverpod
class TeamMembersNotifier extends _$TeamMembersNotifier {
  static const _cacheTtl = Duration(minutes: 1);

  @override
  TeamMembersState build() {
    state = const TeamMembersState();
    Future.microtask(() => _loadPage(0));
    return state;
  }

  Future<void> goToPage(int pageIndex) => _loadPage(pageIndex);

  Future<void> loadNextPage() async {
    if (!state.hasNextPage || state.isLoading) return;
    await _loadPage(state.currentPage + 1);
  }

  Future<void> nextPage() async {
    if (!state.hasNextPage) return;
    await _loadPage(state.currentPage + 1);
  }

  Future<void> previousPage() async {
    if (state.currentPage == 0) return;
    await _loadPage(state.currentPage - 1);
  }

  Future<void> refresh() async {
    final updatedPages = Map<int, List<TeamMember>>.from(state.pagesByIndex)
      ..clear();
    state = state.copyWith(
      dateFilter: const DateFilterRange(type: DateFilterType.none),
      pagesByIndex: updatedPages,
      items: const [],
      lastFetchedAt: null,
    );
    await _loadPage(0);
  }

  void setDateFilter(DateFilterRange filter) {
    final updatedPages = Map<int, List<TeamMember>>.from(state.pagesByIndex)
      ..clear();

    state = state.copyWith(
      dateFilter: filter,
      pagesByIndex: updatedPages,
      items: const [],
      currentPage: 0,
      lastFetchedAt: null,
    );

    // Reload first page with new filter
    _loadPage(0);
  }

  Future<void> updateOperator(EditOperatorForm form) async {
    state = state.copyWith(isLoading: true);
    try {
      final teamUser = ref.read(appUserProvider).value;
      final teamId = teamUser?.teamId;
      if (teamId == null) return;

      final currentMembers = state.pagesByIndex[state.currentPage] ?? [];
      final updatedMembers = currentMembers.map((m) {
        if (m.id == form.id) {
          return m.copyWith(
            email: form.email,
            firstName: form.firstName,
            lastName: form.lastName,
            status: form.status,
          );
        }
        return m;
      }).toList();

      final updatedPages = Map<int, List<TeamMember>>.from(state.pagesByIndex)
        ..[state.currentPage] = updatedMembers;

      final updatedItems = state.items.map((m) {
        if (m.id == form.id) {
          return m.copyWith(
            email: form.email,
            firstName: form.firstName,
            lastName: form.lastName,
            status: form.status,
          );
        }
        return m;
      }).toList();

      state = state.copyWith(
        pagesByIndex: updatedPages,
        members: updatedMembers,
        items: updatedItems,
        lastFetchedAt: DateTime.now(),
      );

      final member = TeamMember(
        id: form.id,
        email: form.email,
        firstName: form.firstName,
        lastName: form.lastName,
        status: form.status,
        addedAt: DateTime.now(),
      );

      await ref
          .read(teamMemberServiceProvider)
          .updateTeamMember(member: member, teamId: teamId);

      await ref.read(appUserServiceProvider).updateUserField(form.id, {
        'status': form.status.value,
      });
    } catch (e) {
      await refresh();
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

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
        items: const [],
        members: const [],
        currentPage: 0,
        isLoading: false,
        hasNextPage: false,
      );
      return;
    }

    final cachedPage = state.pagesByIndex[pageIndex];
    if (cachedPage != null && _isCacheFresh(state.lastFetchedAt)) {
      final newItems = pageIndex == 0
          ? cachedPage
          : [...state.items, ...cachedPage];
      state = state.copyWith(
        currentPage: pageIndex,
        members: cachedPage,
        items: newItems,
        isLoading: false,
      );
      return;
    }
    state = state.copyWith(isLoading: true);

    final service = ref.read(teamMemberServiceProvider);

    final pageMembers = await service.fetchTeamMembersPage(
      teamId: teamId,
      pageSize: state.pageSize,
      pageIndex: pageIndex,
      dateFilter: state.dateFilter,
    );

    final updatedPages = Map<int, List<TeamMember>>.from(state.pagesByIndex)
      ..[pageIndex] = pageMembers;

    final newItems = pageIndex == 0
        ? pageMembers
        : [...state.items, ...pageMembers];

    state = state.copyWith(
      items: newItems,
      members: pageMembers,
      currentPage: pageIndex,
      isLoading: false,
      hasNextPage: pageMembers.length == state.pageSize,
      pagesByIndex: updatedPages,
      lastFetchedAt: DateTime.now(),
    );
  }
}
