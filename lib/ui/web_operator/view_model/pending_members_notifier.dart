import 'package:flutter_application_1/data/providers/auth_providers.dart';
import 'package:flutter_application_1/data/providers/team_providers.dart';
import 'package:flutter_application_1/data/services/api/model/pending_member/pending_member.dart';
import 'package:flutter_application_1/data/utils/result.dart';
import 'package:flutter_application_1/ui/activity_logs/models/activity_common.dart';
import 'package:flutter_application_1/ui/web_operator/providers/operators_date_filter_provider.dart';
import 'package:flutter_application_1/ui/web_operator/providers/operators_search_provider.dart';
import 'package:flutter_application_1/ui/web_operator/view_model/pending_members_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'pending_members_notifier.g.dart';

@riverpod
class PendingMembersNotifier extends _$PendingMembersNotifier {
  void setPageSize(int newSize) {
    if (newSize == state.pageSize) return;
    final updatedPages = Map<int, List<PendingMember>>.from(state.pagesByIndex)
      ..clear();

    state = state.copyWith(
      pageSize: newSize,
      currentPage: 0,
      pagesByIndex: updatedPages,
      items: const [],
      members: const [],
      filteredMembers: const [],
      lastFetchedAt: null,
      hasNextPage: false,
    );
    _loadPage(0);
  }

  static const _cacheTtl = Duration(minutes: 1);

  Future<void> acceptRequest(PendingMember member) async {
    state = state.copyWith(isLoading: true, isError: false, error: null);

    final service = ref.read(pendingMembersServiceProvider);
    final appUser = ref.watch(appUserProvider).value;
    final teamId = appUser?.teamId;

    if (teamId == null) {
      state = state.copyWith(
        isLoading: false,
        isError: true,
        error: Exception('No team ID available'),
      );
      return;
    }

    final result = await service.acceptPendingMember(
      teamId: teamId,
      member: member,
    );

    return switch (result) {
      Ok() => _handleAcceptSuccess(member),
      Error() => _handleAcceptError(result.error),
    };
  }

  @override
  PendingMembersState build() {
    ref.listen(operatorsDateFilterProvider, (previous, next) {
      if (previous != next) {
        _handleFilterOrSearchChange(next, state.searchQuery);
      }
    });

    ref.listen(operatorsSearchProvider, (previous, next) {
      if (previous != next) {
        _handleFilterOrSearchChange(state.dateFilter, next);
      }
    });
    state = const PendingMembersState();
    Future.microtask(() => _loadPage(0));
    return state;
  }

  Future<void> declineRequest(PendingMember member) async {
    state = state.copyWith(isLoading: true, isError: false, error: null);

    final service = ref.read(pendingMembersServiceProvider);
    final appUser = ref.watch(appUserProvider).value;
    final teamId = appUser?.teamId;

    if (teamId == null) {
      state = state.copyWith(
        isLoading: false,
        isError: true,
        error: Exception('No team ID available'),
      );
      return;
    }

    final result = await service.deletePendingMember(
      teamId: teamId,
      docId: member.id,
    );

    return switch (result) {
      Ok() => _handleDeclineSuccess(member),
      Error() => _handleDeclineError(result.error),
    };
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
    final updatedPages = Map<int, List<PendingMember>>.from(state.pagesByIndex)
      ..clear();
    state = state.copyWith(
      dateFilter: const DateFilterRange(type: DateFilterType.none),
      searchQuery: '',
      pagesByIndex: updatedPages,
      items: const [],
      lastFetchedAt: null,
    );
    await _loadPage(0);
  }

  void setDateFilter(DateFilterRange filter) {
    final updatedPages = Map<int, List<PendingMember>>.from(state.pagesByIndex)
      ..clear();

    state = state.copyWith(
      dateFilter: filter,
      pagesByIndex: updatedPages,
      items: const [],
      currentPage: 0,
      lastFetchedAt: null,
    );

    _loadPage(0);
  }

  void _handleAcceptError(Exception error) {
    state = state.copyWith(isLoading: false, isError: true, error: error);
  }

  void _handleAcceptSuccess(PendingMember member) {
    final currentMembers = List<PendingMember>.from(state.members)
      ..removeWhere((m) => m.id == member.id);

    final filteredMembers = _applySearchFilter(currentMembers);

    final updatedPages = Map<int, List<PendingMember>>.from(state.pagesByIndex);
    updatedPages[state.currentPage] = currentMembers;

    final updatedItems = state.items.where((m) => m.id != member.id).toList();

    state = state.copyWith(
      items: updatedItems,
      members: currentMembers,
      filteredMembers: filteredMembers,
      pagesByIndex: updatedPages,
      isLoading: false,
      hasNextPage: currentMembers.length == state.pageSize,
      lastFetchedAt: DateTime.now(),
    );
  }

  void _handleDeclineError(Exception error) {
    state = state.copyWith(isLoading: false, isError: true, error: error);
  }

  void _handleDeclineSuccess(PendingMember member) {
    final currentMembers = List<PendingMember>.from(state.members)
      ..removeWhere((m) => m.id == member.id);

    final filteredMembers = _applySearchFilter(currentMembers);

    final updatedPages = Map<int, List<PendingMember>>.from(state.pagesByIndex);
    updatedPages[state.currentPage] = currentMembers;
    final updatedItems = state.items.where((m) => m.id != member.id).toList();

    state = state.copyWith(
      items: updatedItems,
      members: currentMembers,
      filteredMembers: filteredMembers,
      pagesByIndex: updatedPages,
      isLoading: false,
      hasNextPage: currentMembers.length == state.pageSize,
      lastFetchedAt: DateTime.now(),
    );
  }

  void _handleError(Exception error) {
    state = state.copyWith(
      isLoading: false,
      isError: true,
      error: error,
      items: const [],
      members: const [],
    );
  }

  void _handleSuccess(int pageIndex, List<PendingMember> members) {
    final filteredMembers = _applySearchFilter(members); // ✅ Apply search

    final updatedPages = Map<int, List<PendingMember>>.from(state.pagesByIndex)
      ..[pageIndex] = members; // Store unfiltered for pagination

    final newItems = pageIndex == 0
        ? filteredMembers
        : [...state.items, ...filteredMembers];

    state = state.copyWith(
      items: newItems,
      members: members, // Raw data
      filteredMembers: filteredMembers, // Filtered data for UI
      currentPage: pageIndex,
      isLoading: false,
      isError: false,
      error: null,
      hasNextPage: members.length == state.pageSize,
      pagesByIndex: updatedPages,
      lastFetchedAt: DateTime.now(),
    );
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
        filteredMembers: const [],
        currentPage: 0,
        isLoading: false,
        hasNextPage: false,
      );
      return;
    }

    final cachedPage = state.pagesByIndex[pageIndex];
    if (cachedPage != null && _isCacheFresh(state.lastFetchedAt)) {
      final filteredMembers = _applySearchFilter(cachedPage);
      final newItems = pageIndex == 0
          ? filteredMembers
          : [...state.items, ...filteredMembers];
      state = state.copyWith(
        currentPage: pageIndex,
        members: cachedPage,
        filteredMembers: filteredMembers,
        items: newItems,
        isLoading: false,
        hasNextPage: cachedPage.length == state.pageSize,
      );
      return;
    }

    state = state.copyWith(isLoading: true);

    final service = ref.read(pendingMembersServiceProvider);
    final result = await service.getPendingMembersPage(
      teamId: teamId,
      pageSize: state.pageSize,
      pageIndex: pageIndex,
      dateFilter: state.dateFilter,
    );

    return switch (result) {
      Ok<List<PendingMember>>(value: final members) => _handleSuccess(
        pageIndex,
        members,
      ),
      Error<List<PendingMember>>() => _handleError(result.error),
    };
  }

  void setSearch(String query) {
    state = state.copyWith(searchQuery: query);
    _applyFilters();
  }

  void _handleFilterOrSearchChange(DateFilterRange filter, String searchQuery) {
    final updatedPages = Map<int, List<PendingMember>>.from(state.pagesByIndex)
      ..clear();
    state = state.copyWith(
      dateFilter: filter,
      searchQuery: searchQuery,
      pagesByIndex: updatedPages,
      items: const [],
      currentPage: 0,
      lastFetchedAt: null,
    );
    _loadPage(0);
  }

  void _applyFilters() {
    final query = state.searchQuery.toLowerCase();
    final filtered = state.members.where((member) {
      final matchesSearch =
          query.isEmpty ||
          member.email.toLowerCase().contains(query) ||
          '${member.firstName} ${member.lastName}'.toLowerCase().contains(
            query,
          );
      return matchesSearch;
    }).toList();

    state = state.copyWith(filteredMembers: filtered);
  }

  List<PendingMember> _applySearchFilter(List<PendingMember> members) {
    if (state.searchQuery.isEmpty) return members;

    final query = state.searchQuery.toLowerCase();
    return members.where((member) {
      return member.email.toLowerCase().contains(query) ||
          '${member.firstName} ${member.lastName}'.toLowerCase().contains(
            query,
          );
    }).toList();
  }
}
