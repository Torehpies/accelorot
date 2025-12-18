import 'package:flutter_application_1/data/providers/auth_providers.dart';
import 'package:flutter_application_1/data/providers/team_providers.dart';
import 'package:flutter_application_1/data/repositories/team_management/team_repository.dart';
import 'package:flutter_application_1/data/services/api/model/team/team.dart';
import 'package:flutter_application_1/data/services/contracts/result.dart';
import 'package:flutter_application_1/ui/team_management/widgets/team_management_state.dart';
import 'package:flutter_application_1/utils/ui_message.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'team_management_notifier.g.dart';

@riverpod
class TeamManagementNotifier extends _$TeamManagementNotifier {
  late final TeamRepository _repository;

  @override
  TeamManagementState build() {
    _repository = ref.read(teamRepositoryProvider);
    Future.microtask(() => getTeams());
    return const TeamManagementState();
  }

  Future<void> getTeams({bool forceRefresh = false}) async {
    state = state.copyWith(teams: AsyncLoading());
    state = state.copyWith(
      teams: await AsyncValue.guard(
        () => ref
            .read(teamRepositoryProvider)
            .getTeams(forceRefresh: forceRefresh),
      ),
    );
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

    final result = await _repository.addTeam(team);

    result.when(
      success: (resultTeam) async {
        await getTeams(forceRefresh: true);
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

  void clearError() {
    state = state.copyWith(message: null);
  }
}
