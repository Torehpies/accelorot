import 'package:flutter_application_1/data/providers/auth_providers.dart';
import 'package:flutter_application_1/data/providers/team_providers.dart';
import 'package:flutter_application_1/data/services/api/model/pending_member/pending_member.dart';
import 'package:flutter_application_1/data/utils/result.dart';
import 'package:flutter_application_1/ui/activity_logs/models/activity_common.dart';
import 'package:flutter_application_1/ui/operator_management/providers/operators_date_filter_provider.dart';
import 'package:flutter_application_1/ui/operator_management/providers/operators_search_provider.dart';
import 'package:flutter_application_1/ui/operator_management/view_model/pending_members_state.dart';
import 'package:flutter_application_1/utils/operator_headers.dart';
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

  // ===== ACCEPT / DECLINE =====

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

    if (result is Error) {
      _handleAcceptError(result.error);
      return;
    }

    final teamResult = await ref
        .read(teamServiceProvider)
        .incrementTeamField(
          teamId: teamId,
          field: OperatorHeaders.pendingOperators,
          amount: -1,
        );

    if (teamResult is Error) {
      _handleAcceptError("Error updating team" as Exception);
      return;
    }

    _handleAcceptSuccess(member);
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

    if (result is Error) {
      _handleDeclineError(result.error);
      return;
    }

    final teamResult = await ref
        .read(teamServiceProvider)
        .incrementTeamField(
          teamId: teamId,
          field: OperatorHeaders.pendingOperators,
          amount: -1,
        );

    if (teamResult is Error) {
      _handleDeclineError("Error updating team" as Exception);
      return;
    }

    _handleDeclineSuccess(member);
  }

  // ===== PAGING NAVIGATION =====

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

  // ===== SORT =====

  void onSort(String column) {
    final isAscending = state.sortColumn == column
        ? !state.sortAscending
        : true;

    state = state.copyWith(sortColumn: column, sortAscending: isAscending);

    _applyFilters();
  }

  // ===== ACCEPT / DECLINE HANDLERS =====

  void _handleAcceptError(Exception error) {
    state = state.copyWith(isLoading: false, isError: true, error: error);
  }

  void _handleAcceptSuccess(PendingMember member) {
    final currentMembers = List<PendingMember>.from(state.members)
      ..removeWhere((m) => m.id == member.id);

    final filteredMembers = _applySearchAndSort(currentMembers);

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

    final filteredMembers = _applySearchAndSort(currentMembers);

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
    final filteredMembers = _applySearchAndSort(members);

    final updatedPages = Map<int, List<PendingMember>>.from(state.pagesByIndex)
      ..[pageIndex] = members;

    final newItems = pageIndex == 0
        ? filteredMembers
        : [...state.items, ...filteredMembers];

    state = state.copyWith(
      items: newItems,
      members: members,
      filteredMembers: filteredMembers,
      currentPage: pageIndex,
      isLoading: false,
      isError: false,
      error: null,
      hasNextPage: members.length == state.pageSize,
      pagesByIndex: updatedPages,
      lastFetchedAt: DateTime.now(),
    );
  }

  // ===== CACHE =====

  bool _isCacheFresh(DateTime? lastFetchedAt) {
    if (lastFetchedAt == null) return false;
    return DateTime.now().difference(lastFetchedAt) < _cacheTtl;
  }

  // ===== PAGING LOAD =====

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
      final filteredMembers = _applySearchAndSort(cachedPage);
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

  // ===== SEARCH =====

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

  // ===== FILTER + SORT CORE =====

  /// Called whenever search query or sort changes — filters + sorts current members
  void _applyFilters() {
    final filtered = _applySearchAndSort(state.members);
    state = state.copyWith(filteredMembers: filtered);
  }

  /// Single pipeline: search filter → sort. Used everywhere we need the final list.
  List<PendingMember> _applySearchAndSort(List<PendingMember> members) {
    // 1. Search filter
    List<PendingMember> result = members;
    final query = state.searchQuery.toLowerCase();
    if (query.isNotEmpty) {
      result = result.where((member) {
        return member.email.toLowerCase().contains(query) ||
            '${member.firstName} ${member.lastName}'.toLowerCase().contains(
              query,
            );
      }).toList();
    }

    // 2. Sort
    if (state.sortColumn != null) {
      result = _sortMembers(result, state.sortColumn!, state.sortAscending);
    }

    return result;
  }

  List<PendingMember> _sortMembers(
    List<PendingMember> members,
    String column,
    bool ascending,
  ) {
    final sorted = List<PendingMember>.from(members);
    sorted.sort((a, b) {
      int cmp;
      switch (column) {
        case 'firstName':
          cmp = a.firstName.toLowerCase().compareTo(b.firstName.toLowerCase());
          break;
        case 'lastName':
          cmp = a.lastName.toLowerCase().compareTo(b.lastName.toLowerCase());
          break;
        case 'email':
          cmp = a.email.toLowerCase().compareTo(b.email.toLowerCase());
          break;
        case 'requestedAt':
          cmp = a.requestedAt.compareTo(b.requestedAt);
          break;
        default:
          cmp = 0;
      }
      return ascending ? cmp : -cmp;
    });
    return sorted;
  }
}

