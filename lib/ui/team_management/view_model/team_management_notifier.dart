import 'dart:async';

import 'package:flutter_application_1/data/providers/team_providers.dart';
import 'package:flutter_application_1/data/services/api/model/team/team.dart';
import 'package:flutter_application_1/data/utils/result.dart';
import 'package:flutter_application_1/ui/team_management/view_model/team_management_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'team_management_notifier.g.dart';

@riverpod
class TeamManagementNotifier extends _$TeamManagementNotifier {
  @override
  TeamManagementState build() {
    final initial = const TeamManagementState();
    state = initial;
    Future.microtask(() => _loadPage(0));
    return const TeamManagementState();
  }

  static const _cacheTtl = Duration(minutes: 1);

  bool _isCacheFresh(DateTime? lastFetchedAt) {
    if (lastFetchedAt == null) return false;
    return DateTime.now().difference(lastFetchedAt) < _cacheTtl;
  }

  Future<void> _loadPage(int pageIndex) async {
    if (state.isLoading) return;

    final cachedPage = state.pagesByIndex[pageIndex];
    if (cachedPage != null && _isCacheFresh(state.lastFetchedAt)) {
      state = state.copyWith(
        currentPage: pageIndex,
        teams: cachedPage,
        isLoading: false,
      );
      return;
    }
    state = state.copyWith(isLoading: true);
    
    // Use repository instead of service
    final repo = ref.read(teamRepositoryProvider);

    final result = await repo.fetchTeamsPage(
      pageSize: state.pageSize,
      pageIndex: pageIndex,
    );

    return switch (result) {
      Ok<List<Team>>() => _handleSuccess(pageIndex, result.value),
      Error<List<Team>>() => _handleError(result.error),
    };
  }

  void _handleSuccess(int pageIndex, List<Team> teams) {
    final updatedPages = Map<int, List<Team>>.from(state.pagesByIndex)
      ..[pageIndex] = teams;

    state = state.copyWith(
      teams: teams,
      currentPage: pageIndex,
      isLoading: false,
      hasNextPage: teams.length == state.pageSize,
      pagesByIndex: updatedPages,
      lastFetchedAt: DateTime.now(),
    );
  }

  void _handleError(Exception error) {
    state = state.copyWith(
      isLoading: false,
      teams: [],
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
    final updatedPages = Map<int, List<Team>>.from(state.pagesByIndex)
      ..remove(state.currentPage);
    state = state.copyWith(pagesByIndex: updatedPages, lastFetchedAt: null);
    await _loadPage(state.currentPage);
  }

  Future<void> setPageSize(int pageSize) async {
    if (state.pageSize == pageSize) return;
    
    // Reset pages cache when page size changes because the chunking is different
    state = state.copyWith(
      pageSize: pageSize,
      currentPage: 0,
      pagesByIndex: {}, 
      lastFetchedAt: null,
      isLoading: true
    );
    
    await _loadPage(0);
  }

  void clearError() {
    state = state.copyWith(message: null);
  }
}
