import 'package:flutter_application_1/data/providers/team_providers.dart';
import 'package:flutter_application_1/data/services/api/model/team_member/team_member.dart';
import 'package:flutter_application_1/ui/activity_logs/models/activity_common.dart';
import 'package:flutter_application_1/ui/team_management/models/team_member_filters.dart';
import 'package:flutter_application_1/utils/roles.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'team_detail_notifier.freezed.dart';
part 'team_detail_notifier.g.dart';

@freezed
abstract class TeamDetailState with _$TeamDetailState {
  const factory TeamDetailState({
    @Default(<TeamMember>[]) List<TeamMember> members,
    @Default(<TeamMember>[]) List<TeamMember> filteredAdmins,
    @Default(<TeamMember>[]) List<TeamMember> filteredMembers,
    @Default({}) Map<int, List<TeamMember>> pagesByIndex,
    @Default(0) int currentPage,
    @Default(10) int pageSize,
    @Default(false) bool isLoading,
    @Default(false) bool hasNextPage,
    DateTime? lastFetchedAt,
    @Default(DateFilterRange(type: DateFilterType.none))
    DateFilterRange dateFilter,
    @Default('') String searchQuery,
    String? sortColumn,
    @Default(true) bool sortAscending,
    @Default(TeamMemberStatusFilter.all) TeamMemberStatusFilter statusFilter,
    String? errorMessage,
  }) = _TeamDetailState;
}

@riverpod
class TeamDetailNotifier extends _$TeamDetailNotifier {
  static const _cacheTtl = Duration(minutes: 1);

  @override
  TeamDetailState build(String teamId) {
    state = const TeamDetailState();
    Future.microtask(() => _loadPage(0));
    return state;
  }

  // ===== PAGINATION =====

  Future<void> goToPage(int pageIndex) => _loadPage(pageIndex);

  Future<void> nextPage() async {
    if (!state.hasNextPage) return;
    await _loadPage(state.currentPage + 1);
  }

  Future<void> previousPage() async {
    if (state.currentPage == 0) return;
    await _loadPage(state.currentPage - 1);
  }

  void setPageSize(int newSize) {
    if (newSize == state.pageSize) return;
    final updatedPages = Map<int, List<TeamMember>>.from(state.pagesByIndex)
      ..clear();

    state = state.copyWith(
      pageSize: newSize,
      currentPage: 0,
      pagesByIndex: updatedPages,
      members: const [],
      filteredAdmins: const [],
      filteredMembers: const [],
      lastFetchedAt: null,
      hasNextPage: false,
    );
    _loadPage(0);
  }

  // ===== REFRESH =====

  Future<void> refresh() async {
    final updatedPages = Map<int, List<TeamMember>>.from(state.pagesByIndex)
      ..clear();
    state = state.copyWith(
      pagesByIndex: updatedPages,
      members: const [],
      filteredAdmins: const [],
      filteredMembers: const [],
      lastFetchedAt: null,
    );
    await _loadPage(state.currentPage);
  }

  // ===== SEARCH =====

  void setSearch(String query) {
    state = state.copyWith(searchQuery: query);
    _applyFilters();
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
    state = state.copyWith(statusFilter: filter);
    _applyFilters();
  }

  // ===== DATE FILTER =====

  void setDateFilter(DateFilterRange filter) {
    final updatedPages = Map<int, List<TeamMember>>.from(state.pagesByIndex)
      ..clear();

    state = state.copyWith(
      dateFilter: filter,
      pagesByIndex: updatedPages,
      members: const [],
      filteredAdmins: const [],
      filteredMembers: const [],
      currentPage: 0,
      lastFetchedAt: null,
    );

    _loadPage(0);
  }

  // ===== CACHE =====

  bool _isCacheFresh(DateTime? lastFetchedAt) {
    if (lastFetchedAt == null) return false;
    return DateTime.now().difference(lastFetchedAt) < _cacheTtl;
  }

  // ===== PAGE LOADING =====

  Future<void> _loadPage(int pageIndex) async {
    if (state.isLoading) return;

    // Check cache first
    final cachedPage = state.pagesByIndex[pageIndex];
    if (cachedPage != null && _isCacheFresh(state.lastFetchedAt)) {
      state = state.copyWith(
        currentPage: pageIndex,
        members: cachedPage,
        isLoading: false,
        hasNextPage: cachedPage.length == state.pageSize,
      );
      _applyFilters();
      return;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final service = ref.read(teamMemberServiceProvider);

      final pageMembers = await service.fetchTeamMembersPage(
        teamId: teamId,
        pageSize: state.pageSize,
        pageIndex: pageIndex,
        dateFilter: state.dateFilter,
      );

      final updatedPages = Map<int, List<TeamMember>>.from(state.pagesByIndex)
        ..[pageIndex] = pageMembers;

      state = state.copyWith(
        members: pageMembers,
        currentPage: pageIndex,
        isLoading: false,
        hasNextPage: pageMembers.length == state.pageSize,
        pagesByIndex: updatedPages,
        lastFetchedAt: DateTime.now(),
      );

      _applyFilters();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Error loading team members: ${e.toString()}',
      );
    }
  }

  // ===== FILTER + SORT CORE =====

  /// Called whenever search, sort, or status filter changes.
  /// Applies the pipeline then splits by TeamRole.
  void _applyFilters() {
    final filtered = _applySearchAndSort(state.members);

    state = state.copyWith(
      filteredAdmins: filtered
          .where((m) => m.teamRole == TeamRole.admin)
          .toList(),
      filteredMembers: filtered
          .where((m) => m.teamRole != TeamRole.admin)
          .toList(),
    );
  }

  /// Single pipeline: search filter -> status filter -> sort.
  List<TeamMember> _applySearchAndSort(List<TeamMember> members) {
    List<TeamMember> result = members;

    // 1. Search filter
    final query = state.searchQuery.toLowerCase();
    if (query.isNotEmpty) {
      result = result.where((member) {
        return member.email.toLowerCase().contains(query) ||
            '${member.firstName} ${member.lastName}'.toLowerCase().contains(
              query,
            );
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
          cmp = b.lastName.toLowerCase().compareTo(b.lastName.toLowerCase());
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
      default:
        return '';
    }
  }
}

