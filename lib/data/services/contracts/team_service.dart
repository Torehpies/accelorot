import 'package:flutter_application_1/data/services/api/model/team/team.dart';
import 'package:flutter_application_1/data/services/contracts/data_layer_error.dart';
import 'package:flutter_application_1/data/services/contracts/result.dart';

abstract class TeamService {
  Future<Result<Team, DataLayerError>> getTeam(String id);
  Future<Result<List<Team>, DataLayerError>> getTeams();
  Future<Result<Team, DataLayerError>> addTeam(Team team);
}
