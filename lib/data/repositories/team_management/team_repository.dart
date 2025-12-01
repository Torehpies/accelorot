import 'package:flutter_application_1/data/models/team.dart';
import 'package:flutter_application_1/data/services/contracts/data_layer_error.dart';
import 'package:flutter_application_1/data/services/contracts/result.dart';

abstract class TeamRepository {
  Future<Result<List<Team>, DataLayerError>> getTeams();
  Future<Result<Team, DataLayerError>> addTeam({
    required String teamName,
    required String address,
    required String createdBy,
  });
}
