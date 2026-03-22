// lib/ui/operator_management/view_model/team_members_notifier.dart

import 'package:flutter_application_1/data/providers/app_user_providers.dart';
import 'package:flutter_application_1/data/providers/auth_providers.dart';
import 'package:flutter_application_1/data/providers/team_providers.dart';
import 'package:flutter_application_1/data/services/api/model/team_member/team_member.dart';
import 'package:flutter_application_1/data/utils/result.dart';
import 'package:flutter_application_1/ui/activity_logs/models/activity_common.dart';
import 'package:flutter_application_1/ui/operator_management/models/team_member_filters.dart';
import 'package:flutter_application_1/ui/operator_management/providers/operators_date_filter_provider.dart';
import 'package:flutter_application_1/ui/operator_management/providers/operators_search_provider.dart';
import 'package:flutter_application_1/ui/operator_management/dialogs/edit_operator_dialog.dart';
import 'package:flutter_application_1/utils/operator_headers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'team_members_state.dart';

part 'team_members_notifier.g.dart';

@Riverpod(keepAlive: true)
class TeamMembersNotifier extends _$TeamMembersNotifier {

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
    Future.microtask(() => _loadAll());
    return state;
  }

  // ===== LOAD =====

  Future<void> _loadAll() async {
    if (state.isLoading) return;

    final teamUser = ref.read(appUserProvider).value;
    final teamId = teamUser?.teamId;
    if (teamId == null || teamId.isEmpty) {
      state = state.copyWith(
        allMembers: const [],
        filteredMembers: const [],
        currentPage: 0,
        isLoading: false,
      );
      return;
    }

    state = state.copyWith(isLoading: true);

    final members = await ref
        .read(teamMemberServiceProvider)
        .fetchAllTeamMembers(
          teamId: teamId,
          dateFilter: state.dateFilter,
        );

    state = state.copyWith(
      allMembers: members,
      isLoading: false,
    );

    _applyFilters();
  }

  // ===== REFRESH =====

  Future<void> refresh() async {
    state = state.copyWith(
      allMembers: const [],
      filteredMembers: const [],
      currentPage: 0,
      displayLimit: 15,
      dateFilter: const DateFilterRange(type: DateFilterType.none),
    );
    await _loadAll();
  }

  // ===== WEB PAGINATION — pure UI state, zero Firestore calls =====

  void onPageChanged(int page) {
    // page is 0-based
    state = state.copyWith(currentPage: page);
  }

  void onItemsPerPageChanged(int size) {
    state = state.copyWith(itemsPerPage: size, currentPage: 0);
  }

  // ===== MOBILE INFINITE SCROLL =====

  /// Reveals the next batch of already-loaded items.
  /// Called by the scroll listener when approaching the bottom of the list.
  void loadMoreItems() {
    if (!state.hasMoreToLoad) return;
    state = state.copyWith(
      displayLimit: state.displayLimit + 15,
    );
  }

  // ===== DATE FILTER — must re-fetch since it's a Firestore where clause =====

  void setDateFilter(DateFilterRange filter) {
    state = state.copyWith(
      dateFilter: filter,
      allMembers: const [],
      filteredMembers: const [],
      currentPage: 0,
    );
    _loadAll();
  }

  // ===== SORT =====

  void onSort(String column) {
    final isAscending = state.sortColumn == column
        ? !state.sortAscending
        : true;

    state = state.copyWith(sortColumn: column, sortAscending: isAscending);
    _applyFilters();
  }

  // ===== STATUS FILTER =====

  void setStatusFilter(TeamMemberStatusFilter filter) {
    state = state.copyWith(statusFilter: filter, currentPage: 0);
    _applyFilters();
  }

  // ===== SEARCH =====

  void setSearch(String query) {
    state = state.copyWith(searchQuery: query, currentPage: 0);
    _applyFilters();
  }

  // ===== UPDATE =====

  Future<void> updateOperator(EditOperatorForm form) async {
    state = state.copyWith(isLoading: true);
    try {
      final teamUser = ref.read(appUserProvider).value;
      final teamId = teamUser?.teamId;
      if (teamId == null) return;

      // Find old member from allMembers — no pagesByIndex lookup needed
      final oldMember = state.allMembers.firstWhere((m) => m.id == form.id);
      final oldStatus = oldMember.status;

      // Optimistic update directly on allMembers
      final updatedAll = state.allMembers.map((m) {
        if (m.id != form.id) return m;
        return m.copyWith(
          email: form.email,
          firstName: form.firstName,
          lastName: form.lastName,
          status: form.status,
        );
      }).toList();

      state = state.copyWith(allMembers: updatedAll);
      _applyFilters(); // re-slice immediately so UI reflects the change

      final member = TeamMember(
        id: form.id,
        email: form.email,
        firstName: form.firstName,
        lastName: form.lastName,
        status: form.status,
        addedAt: DateTime.now(),
      );

      final memberResult = await ref
          .read(teamMemberServiceProvider)
          .updateTeamMember(member: member, teamId: teamId);

      if (memberResult.isFailure) {
        await refresh();
        return;
      }

      if (oldStatus != form.status) {
        final fromHeader = mapStatusToOperatorHeader(oldStatus);
        final toHeader = mapStatusToOperatorHeader(form.status);
        if (fromHeader != null && toHeader != null) {
          final teamResult = await ref
              .read(teamServiceProvider)
              .updateTeamField(
                teamId: teamId,
                from: fromHeader,
                to: toHeader,
                amount: 1,
              );

          if (teamResult is Error<String>) {
            await refresh();
            return;
          }
        }
      }

      final userResult = await ref.read(appUserServiceProvider).updateUserField(
        form.id,
        {'status': form.status.value},
      );

      if (userResult.isFailure) {
        await refresh();
        return;
      }

      ref.invalidate(currentTeamProvider);
    } catch (e) {
      await refresh();
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  // ===== FILTER/SEARCH CHANGE HANDLER (from provider listeners) =====

  void _handleFilterOrSearchChange(DateFilterRange filter, String searchQuery) {
    // Date filter changed — must re-fetch from Firestore
    // Search query changed — re-filter in memory only
    final dateChanged = filter != state.dateFilter;

    state = state.copyWith(
      dateFilter: filter,
      searchQuery: searchQuery,
      allMembers: dateChanged ? const [] : state.allMembers,
      filteredMembers: const [],
      currentPage: 0,
      displayLimit: 15,
    );

    if (dateChanged) {
      _loadAll();
    } else {
      _applyFilters();
    }
  }

  // ===== FILTER + SORT CORE =====

  /// Called whenever search, sort, or status filter changes.
  /// Operates entirely on allMembers in memory — no Firestore calls.
  void _applyFilters() {
    final filtered = _applySearchAndSort(state.allMembers);
    state = state.copyWith(filteredMembers: filtered);
  }

  /// Single pipeline: search filter → status filter → sort.
  List<TeamMember> _applySearchAndSort(List<TeamMember> members) {
    List<TeamMember> result = members;

    // 1. Search filter
    final query = state.searchQuery.toLowerCase();
    if (query.isNotEmpty) {
      result = result.where((member) {
        return member.email.toLowerCase().contains(query) ||
            '${member.firstName} ${member.lastName}'
                .toLowerCase()
                .contains(query);
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