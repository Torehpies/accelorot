import 'package:flutter_application_1/data/providers/team_providers.dart';
import 'package:flutter_application_1/data/services/api/model/team/team.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'add_team_notifier.g.dart';

@riverpod
class AddTeamNotifier extends _$AddTeamNotifier {
  @override
  FutureOr<void> build() {
    return null;
  }

  Future<void> addTeam(Team team) async {
    final teamRepo = ref.read(teamRepositoryProvider);
    state = AsyncLoading();
    state = await AsyncValue.guard(() async {
      await teamRepo.addTeam(team);
    });
  }
}
