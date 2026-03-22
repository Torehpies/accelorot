import 'package:flutter_application_1/data/services/api/model/team/team.dart';
import 'package:flutter_application_1/data/services/contracts/data_layer_error.dart';
import 'package:flutter_application_1/data/services/contracts/result.dart';

import 'package:flutter_application_1/data/utils/result.dart' as utils;

abstract class TeamRepository {
  Future<List<Team>> getTeams({bool forceRefresh = false});
  Future<utils.Result<List<Team>>> fetchTeamsPage({
    required int pageSize,
    required int pageIndex,
  });
  Future<Team> addTeam(Team team);
  Future<Result<void, DataLayerError>> requestToJoinTeam(
    String teamId,
    String userId,
    String email,
    String firstName,
    String lastName,
  );
  Future<Result<bool, DataLayerError>> isInTeam(String userId);
  void clearCache();
}
