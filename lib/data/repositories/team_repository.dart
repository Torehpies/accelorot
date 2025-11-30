import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_application_1/data/services/contracts/data_layer_error.dart';
import 'package:flutter_application_1/data/services/contracts/result.dart';
import 'package:flutter_application_1/data/services/contracts/team_service.dart';
import 'package:flutter_application_1/data/utils/map_firebase_exception.dart';

abstract class TeamRepository {
  Future<Result<void, DataLayerError>> addTeam({
    required String teamName,
    required String address,
    required String createdBy,
  });
}

class TeamRepositoryImpl implements TeamRepository {
  final TeamService _teamService;

  TeamRepositoryImpl(this._teamService);

  @override
  Future<Result<void, DataLayerError>> addTeam({
    required String teamName,
    required String address,
    required String createdBy,
  }) async {
    try {
      await _teamService.addTeam(teamName, address, createdBy);
      return const Result.success(null);
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
