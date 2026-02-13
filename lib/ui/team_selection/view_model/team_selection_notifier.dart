import 'package:flutter_application_1/data/models/app_user.dart';
import 'package:flutter_application_1/data/providers/auth_providers.dart';
import 'package:flutter_application_1/data/providers/team_providers.dart';
import 'package:flutter_application_1/data/services/api/model/team/team.dart';
import 'package:flutter_application_1/data/services/contracts/result.dart';
import 'package:flutter_application_1/ui/team_selection/view_model/team_selection_state.dart';
import 'package:flutter_application_1/utils/operator_headers.dart';
import 'package:flutter_application_1/utils/ui_message.dart';
import 'package:flutter_application_1/data/utils/result.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'team_selection_notifier.g.dart';

@riverpod
class TeamSelectionNotifier extends _$TeamSelectionNotifier {
  @override
  TeamSelectionState build() {
    Future.microtask(() => loadTeams());
    return const TeamSelectionState();
  }

  Future<void> loadTeams() async {
    state = state.copyWith(teams: AsyncLoading());
    state = state.copyWith(
      teams: await AsyncValue.guard(
        () => ref.read(teamRepositoryProvider).getTeams(),
      ),
    );
    // result.when(
    //   success: (teams) {
    //     state = state.copyWith(teams: teams, isLoadingTeams: false);
    //   },
    //   failure: (failure) {
    //     _setError(failure.userFriendlyMessage);
    //   },
    // );
  }

  void selectedTeam(Team team) {
    state = state.copyWith(selectedTeam: team);
  }

  Future<void> submitTeamRequest(AppUser user) async {
    state = state.copyWith(isSubmitting: true);

    final team = state.selectedTeam;
    if (team == null) {
      _setError("No team selected.");
      return;
    }

    final teamId = team.teamId;

    final userId = user.uid;
    final email = user.email;

    // if (email == null) {
    //   _setError("Email is missing.");
    //   return;
    // }

    try {
      final result = await ref
          .read(teamRepositoryProvider)
          .requestToJoinTeam(
            teamId!,
            userId,
            email,
            user.firstname,
            user.lastname,
          );

      if (result is Error) {
        _setError(result.asFailure.userFriendlyMessage);
        return;
      }

      final teamResult = await ref
          .read(teamServiceProvider)
          .incrementTeamField(
            teamId: teamId,
            field: OperatorHeaders.pendingOperators,
            amount: 1,
          );

      if (teamResult is Error<String>) {
        _setError("Error updating team summary");
        return;
      }
      _setSuccess("Request submitted!");
    } catch (e) {
      _setError("Unexpected error: $e");
    }
  }

  Future<void> handleBackToLogin() async {
    await ref.read(authRepositoryProvider).signOut();
  }

  void _setError(String message) {
    state = state.copyWith(
      isSubmitting: false,
      message: UiMessage.error(message),
    );
  }

  void _setSuccess(String message) {
    state = state.copyWith(
      isSubmitting: false,
      message: UiMessage.success(message),
    );
  }
}
