import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_application_1/data/models/team.dart';
import 'package:flutter_application_1/data/repositories/team_management/team_repository.dart';
import 'package:flutter_application_1/data/services/contracts/data_layer_error.dart';
import 'package:flutter_application_1/data/services/contracts/result.dart';
import 'package:flutter_application_1/data/services/contracts/team_service.dart';
import 'package:flutter_application_1/data/utils/map_firebase_exception.dart';
import 'package:flutter_application_1/repositories/team_repository.dart';


class TeamRepositoryRemote implements TeamRepository {
  TeamRepositoryRemote(this._teamService);

  final TeamService _teamService;
	List<Team>? _cachedTeams;

  @override
  Future<Result<Team, DataLayerError>> addTeam({
    required String teamName,
    required String address,
    required String createdBy,
  }) async {
      await _teamService.addTeam(teamName, address, createdBy);

      return const Result.success(null);
  }

  @override
  Future<Result<List<Team>, DataLayerError>> getTeams() async {
    try {
      final rawData = await _teamService.fetchRawTeams();
      final teams = rawData.docs.map((doc) {
        final data = doc.data();

        return Team.fromJson({...?data, 'id': doc.id});
      }).toList();
      return Result.success(teams);
    } on FirebaseException catch (e) {
      return Result.failure(mapFirebaseException(e));
    } on TypeError catch (_) {
      return const Result.failure(DataLayerError.mappingError());
    } on FormatException catch (_) {
      return const Result.failure(DataLayerError.mappingError());
    } catch (e) {
      return Result.failure(DataLayerError.unknownError(e));
    }
  }
}
