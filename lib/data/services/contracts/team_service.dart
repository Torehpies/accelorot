import 'package:flutter_application_1/data/services/api/model/team/team.dart';
import 'package:flutter_application_1/data/services/contracts/data_layer_error.dart';
import 'package:flutter_application_1/data/services/contracts/result.dart';
import 'package:flutter_application_1/data/utils/result.dart' as prefix;

abstract class TeamService {
  Future<Team> getTeam(String id);
  Future<Result<List<Team>, DataLayerError>> getTeams();
  Future<Result<Team, DataLayerError>> addTeam(Team team);
  Future<prefix.Result<List<Team>>> fetchTeamsPage({
    required int pageSize,
    required int pageIndex,
  });
}
