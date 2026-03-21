// lib/ui/operator_management/view_model/pending_members_notifier.dart

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
    Future.microtask(() => _loadAll());
    return state;
  }

  // ===== LOAD =====

  Future<void> _loadAll() async {
    if (state.isLoading) return;

    final appUser = ref.read(appUserProvider).value;
    final teamId = appUser?.teamId;
    if (teamId == null || teamId.isEmpty) {
      state = state.copyWith(
        allMembers: const [],
        filteredMembers: const [],
        currentPage: 0,
        isLoading: false,
      );
      return;
    }

    state = state.copyWith(isLoading: true, isError: false, error: null);

    final service = ref.read(pendingMembersServiceProvider);
    final result = await service.getAllPendingMembers(
      teamId: teamId,
      dateFilter: state.dateFilter,
    );

    if (result is Ok<List<PendingMember>>) {
      state = state.copyWith(
        allMembers: result.value,
        isLoading: false,
        isError: false,
        error: null,
      );
      _applyFilters();
    } else if (result is Error<List<PendingMember>>) {
      state = state.copyWith(
        isLoading: false,
        isError: true,
        error: result.error,
        allMembers: const [],
        filteredMembers: const [],
      );
    }
  }

  // ===== REFRESH =====

  Future<void> refresh() async {
    state = state.copyWith(
      allMembers: const [],
      filteredMembers: const [],
      currentPage: 0,
      displayLimit: 15,
      dateFilter: const DateFilterRange(type: DateFilterType.none),
      searchQuery: '',
      isError: false,
      error: null,
    );
    await _loadAll();
  }

  // ===== WEB PAGINATION — pure UI state, zero Firestore calls =====

  void onPageChanged(int page) {
    state = state.copyWith(currentPage: page);
  }

  void onItemsPerPageChanged(int size) {
    state = state.copyWith(itemsPerPage: size, currentPage: 0);
  }

  // ===== MOBILE INFINITE SCROLL =====

  void loadMoreItems() {
    if (!state.hasMoreToLoad) return;
    state = state.copyWith(displayLimit: state.displayLimit + 15);
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
    final isAscending = state.sortColumn == column ? !state.sortAscending : true;
    state = state.copyWith(sortColumn: column, sortAscending: isAscending);
    _applyFilters();
  }

  // ===== SEARCH =====

  void setSearch(String query) {
    state = state.copyWith(searchQuery: query, currentPage: 0);
    _applyFilters();
  }

  // ===== ACCEPT =====

  Future<void> acceptRequest(PendingMember member) async {
    state = state.copyWith(isLoading: true, isError: false, error: null);

    final service = ref.read(pendingMembersServiceProvider);
    final appUser = ref.read(appUserProvider).value;
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
        .updateTeamField(
          teamId: teamId,
          from: OperatorHeaders.pendingOperators,
          to: OperatorHeaders.activeOperators,
          amount: 1,
        );

    if (teamResult is Error) {
      _handleAcceptError('Error updating team' as Exception);
      return;
    }

    ref.invalidate(currentTeamProvider);
    _handleMemberRemoved(member, isLoading: false);
  }

  // ===== DECLINE =====

  Future<void> declineRequest(PendingMember member) async {
    state = state.copyWith(isLoading: true, isError: false, error: null);

    final service = ref.read(pendingMembersServiceProvider);
    final appUser = ref.read(appUserProvider).value;
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
        .updateTeamField(
          teamId: teamId,
          from: OperatorHeaders.pendingOperators,
          to: OperatorHeaders.activeOperators,
          amount: 1,
        );

    if (teamResult is Error) {
      _handleDeclineError('Error updating team' as Exception);
      return;
    }

    _handleMemberRemoved(member, isLoading: false);
  }

  // ===== ACCEPT / DECLINE HANDLERS =====

  void _handleAcceptError(Exception error) {
    state = state.copyWith(isLoading: false, isError: true, error: error);
  }

  void _handleDeclineError(Exception error) {
    state = state.copyWith(isLoading: false, isError: true, error: error);
  }

  void _handleMemberRemoved(PendingMember member, {required bool isLoading}) {
    final updatedAll = state.allMembers
        .where((m) => m.id != member.id)
        .toList();

    state = state.copyWith(allMembers: updatedAll, isLoading: isLoading);
    _applyFilters();
  }

  // ===== FILTER/SEARCH CHANGE HANDLER (from provider listeners) =====

  void _handleFilterOrSearchChange(DateFilterRange filter, String searchQuery) {
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

  void _applyFilters() {
    final filtered = _applySearchAndSort(state.allMembers);
    state = state.copyWith(filteredMembers: filtered);
  }

  List<PendingMember> _applySearchAndSort(List<PendingMember> members) {
    List<PendingMember> result = members;

    final query = state.searchQuery.toLowerCase();
    if (query.isNotEmpty) {
      result = result.where((member) {
        return member.email.toLowerCase().contains(query) ||
            '${member.firstName} ${member.lastName}'
                .toLowerCase()
                .contains(query);
      }).toList();
    }

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