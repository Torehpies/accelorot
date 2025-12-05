import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_application_1/data/services/api/model/team/team.dart';
import 'package:flutter_application_1/data/services/contracts/data_layer_error.dart';
import 'package:flutter_application_1/data/services/contracts/result.dart';
import 'package:flutter_application_1/data/services/contracts/team_service.dart';
import 'package:flutter_application_1/data/utils/map_firebase_exception.dart';

class FirebaseTeamService implements TeamService {
  final FirebaseFirestore _firestore;
  FirebaseTeamService(this._firestore);

  @override
  Future<Result<Team, DataLayerError>> getTeam(String teamId) async {
    try {
      final doc = await _firestore.collection('teams').doc(teamId).get();
      final raw = doc.data();
      if (raw == null) {
        return Result.failure(DataLayerError.dataEmptyError());
      }
			debugPrint(raw.toString());
      final team = Team.fromJson(raw);
      return Result.success(team);
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

  @override
  Future<Result<List<Team>, DataLayerError>> getTeams() async {
    try {
      final snapshot = await _firestore.collection('teams').get();
      final teams = snapshot.docs
          .map((doc) => Team.fromJson(doc.data()))
          .toList();
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

  @override
  Future<Result<Team, DataLayerError>> addTeam(Team team) async {
    try {
			final docRef = _firestore.collection('teams').doc();
			final updatedTeam = team.copyWith(teamId: docRef.id);
      await docRef.set(updatedTeam.toJson());
			return Result.success(updatedTeam);

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
