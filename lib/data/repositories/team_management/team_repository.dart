import 'package:flutter_application_1/data/services/api/model/team/team.dart';
import 'package:flutter_application_1/data/services/contracts/data_layer_error.dart';
import 'package:flutter_application_1/data/services/contracts/result.dart';

abstract class TeamRepository {
  Future<List<Team>> getTeams({
    bool forceRefresh = false,
  });
  Future<Result<Team, DataLayerError>> addTeam(Team team);
  Future<Result<void, DataLayerError>> requestToJoinTeam(String teamId, String userId, String email);
  Future<Result<bool, DataLayerError>> isInTeam(String userId);
	void clearCache();
}
