import 'package:flutter_application_1/data/repositories/team_management/team_repository.dart';
import 'package:flutter_application_1/data/services/api/model/team/team.dart';
import 'package:flutter_application_1/data/services/contracts/data_layer_error.dart';
import 'package:flutter_application_1/data/services/contracts/result.dart';
import 'package:flutter_application_1/data/services/contracts/team_service.dart';

class TeamRepositoryRemote implements TeamRepository {
  TeamRepositoryRemote(this._teamService);

  final TeamService _teamService;
  List<Team>? _cachedTeams;

  @override
  Future<Result<Team, DataLayerError>> addTeam(Team team) async {
    final result = await _teamService.addTeam(team);

    result.when(
      success: (team) => _cachedTeams?.add(team),
      failure: (_) => _cachedTeams,
    );

		return result;
  }

  @override
  Future<Result<List<Team>, DataLayerError>> getTeams({
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && _cachedTeams != null) {
      return Result.success(_cachedTeams!);
    }

    final result = await _teamService.getTeams();

    result.when(
      success: (teams) => _cachedTeams = teams,
      failure: (_) => _cachedTeams,
    );

    return result;
  }

  @override
  void clearCache() {
    _cachedTeams = null;
  }
}
