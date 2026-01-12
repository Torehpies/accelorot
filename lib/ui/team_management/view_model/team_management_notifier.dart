import 'package:flutter_application_1/data/providers/auth_providers.dart';
import 'package:flutter_application_1/data/providers/team_providers.dart';
import 'package:flutter_application_1/data/services/api/model/team/team.dart';
import 'package:flutter_application_1/data/services/contracts/result.dart';
import 'package:flutter_application_1/data/utils/result.dart';
import 'package:flutter_application_1/ui/team_management/widgets/team_management_state.dart';
import 'package:flutter_application_1/utils/ui_message.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'team_management_notifier.g.dart';

@riverpod
class TeamManagementNotifier extends _$TeamManagementNotifier {
  @override
  TeamManagementState build() {
    state = const TeamManagementState();
    Future.microtask(() => _loadPage(0));
    return const TeamManagementState();
  }

  Future<void> addTeam(String teamName, String address) async {
    final user = ref.watch(appUserProvider).value;

    teamName = teamName.trim();
    address = address.trim();

    if (teamName.isEmpty || address.isEmpty) {
      state = state.copyWith(
        message: UiMessage.error("Please fill out fields."),
      );
      return;
    }

    state = state.copyWith(isSavingTeams: true);

    final team = Team.fromJson({
      'teamName': teamName,
      'address': address,
      'createdBy': user?.uid,
    });

    final result = await ref.read(teamRepositoryProvider).addTeam(team);

    result.when(
      success: (resultTeam) async {
				await refresh();
        state = state.copyWith(
          isSavingTeams: false,
          message: UiMessage.success('Team $teamName added successfully!'),
        );
      },
      failure: (e) {
        state = state.copyWith(
          isSavingTeams: false,
          message: UiMessage.error(e.userFriendlyMessage),
        );
      },
    );
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

    final service = ref.read(teamServiceProvider);

    final result = await service.fetchTeamsPage(
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
      // isError: false,
      // error: null,
      hasNextPage: teams.length == state.pageSize,
      pagesByIndex: updatedPages,
      lastFetchedAt: DateTime.now(),
    );
  }

  void _handleError(Exception error) {
    state = state.copyWith(
      isLoading: false,
      // isError: true,
      // error: error,
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

  void clearError() {
    state = state.copyWith(message: null);
  }
}
