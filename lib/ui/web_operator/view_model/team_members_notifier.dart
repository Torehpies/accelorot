// lib/ui/web_operator/view_model/team_members_notifier.dart

import 'package:flutter_application_1/data/providers/app_user_providers.dart';
import 'package:flutter_application_1/data/providers/auth_providers.dart';
import 'package:flutter_application_1/data/providers/team_providers.dart';
import 'package:flutter_application_1/data/services/api/model/team_member/team_member.dart';
import 'package:flutter_application_1/ui/activity_logs/models/activity_common.dart';
import 'package:flutter_application_1/ui/web_operator/models/team_member_filters.dart';
import 'package:flutter_application_1/ui/web_operator/providers/operators_date_filter_provider.dart';
import 'package:flutter_application_1/ui/web_operator/providers/operators_search_provider.dart';
import 'package:flutter_application_1/ui/web_operator/widgets/edit_operator_dialog.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'team_members_state.dart';

part 'team_members_notifier.g.dart';

@riverpod
class TeamMembersNotifier extends _$TeamMembersNotifier {
  void setPageSize(int newSize) {
    if (newSize == state.pageSize) return;
    final updatedPages = Map<int, List<TeamMember>>.from(state.pagesByIndex)
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

  @override
  TeamMembersState build() {
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

  // ===== SORT =====

  void onSort(String column) {
    final isAscending = state.sortColumn == column
        ? !state.sortAscending
        : true;

    state = state.copyWith(sortColumn: column, sortAscending: isAscending);

    _applyFilters();
  }

  // ===== STATUS FILTERING =====
  
  void setStatusFilter(TeamMemberStatusFilter filter) {
    state = state.copyWith(statusFilter: filter);
    _applyFilters();
  }

  // ===== UPDATE =====

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

      final updatedFilteredMembers = _applySearchAndSort(updatedMembers);

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
        filteredMembers: updatedFilteredMembers,
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

  // ===== CACHE =====

  bool _isCacheFresh(DateTime? lastFetchedAt) {
    if (lastFetchedAt == null) return false;
    return DateTime.now().difference(lastFetchedAt) < _cacheTtl;
  }

  // ===== PAGING =====

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
      final filteredMembers = _applySearchAndSort(cachedPage);
      final newItems = pageIndex == 0
          ? cachedPage
          : [...state.items, ...cachedPage];
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

    final service = ref.read(teamMemberServiceProvider);

    final pageMembers = await service.fetchTeamMembersPage(
      teamId: teamId,
      pageSize: state.pageSize,
      pageIndex: pageIndex,
      dateFilter: state.dateFilter,
    );

    final filteredMembers = _applySearchAndSort(pageMembers);
    final updatedPages = Map<int, List<TeamMember>>.from(state.pagesByIndex)
      ..[pageIndex] = pageMembers;

    final newItems = pageIndex == 0
        ? filteredMembers
        : [...state.items, ...filteredMembers];

    state = state.copyWith(
      items: newItems,
      members: pageMembers,
      filteredMembers: filteredMembers,
      currentPage: pageIndex,
      isLoading: false,
      hasNextPage: pageMembers.length == state.pageSize,
      pagesByIndex: updatedPages,
      lastFetchedAt: DateTime.now(),
    );
  }

  // ===== SEARCH =====

  void setSearch(String query) {
    state = state.copyWith(searchQuery: query);
    _applyFilters();
  }

  void _handleFilterOrSearchChange(DateFilterRange filter, String searchQuery) {
    final updatedPages = Map<int, List<TeamMember>>.from(state.pagesByIndex)
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

  /// Single pipeline: search filter → status filter → sort. Used everywhere we need the final list.
  List<TeamMember> _applySearchAndSort(List<TeamMember> members) {
    List<TeamMember> result = members;
    
    // 1. Search filter
    final query = state.searchQuery.toLowerCase();
    if (query.isNotEmpty) {
      result = result.where((member) {
        return member.email.toLowerCase().contains(query) ||
            '${member.firstName} ${member.lastName}'.toLowerCase().contains(query);
      }).toList();
    }

    // 2. Status filter
    if (state.statusFilter != TeamMemberStatusFilter.all) {
      final targetStatus = _getStatusValue(state.statusFilter);
      result = result.where((member) {
        return member.status.value.toLowerCase() == targetStatus;
      }).toList();
    }

    // 3. Sort
    if (state.sortColumn != null) {
      result = _sortMembers(result, state.sortColumn!, state.sortAscending);
    }

    return result;
  }

  List<TeamMember> _sortMembers(
    List<TeamMember> members,
    String column,
    bool ascending,
  ) {
    final sorted = List<TeamMember>.from(members);
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
        case 'status':
          cmp = a.status.value.toLowerCase().compareTo(
            b.status.value.toLowerCase(),
          );
          break;
        default:
          cmp = 0;
      }
      return ascending ? cmp : -cmp;
    });
    return sorted;
  }

  // Helper method to convert enum to status value
  String _getStatusValue(TeamMemberStatusFilter filter) {
    switch (filter) {
      case TeamMemberStatusFilter.active:
        return 'active';
      case TeamMemberStatusFilter.removed:
        return 'removed';
      case TeamMemberStatusFilter.archived:
        return 'archived';
      case TeamMemberStatusFilter.all:
        return '';
    }
  }
}