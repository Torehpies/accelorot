import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/data/services/api/model/team/team.dart';
import 'package:flutter_application_1/data/services/contracts/data_layer_error.dart';
import 'package:flutter_application_1/data/services/contracts/result.dart';
import 'package:flutter_application_1/data/services/contracts/team_service.dart';
import 'package:flutter_application_1/data/utils/map_firebase_exception.dart';
import 'package:flutter_application_1/data/utils/result.dart' as prefix;

class FirebaseTeamService implements TeamService {
  final FirebaseFirestore _firestore;
  FirebaseTeamService(this._firestore);

  CollectionReference<Map<String, dynamic>> _teamsRef() {
    return _firestore.collection('teams');
  }

  @override
  Future<Team> getTeam(String teamId) async {
    try {
      final doc = await _firestore.collection('teams').doc(teamId).get();

      if (!doc.exists) {
        throw Exception('Team $teamId not found');
      }

      final raw = doc.data()!;
      return Team.fromJson(raw);
    } on FirebaseException catch (e) {
      throw Exception('Failed to fetch team: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error fetching team: $e');
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
      debugPrint(e.toString());
      return Result.failure(mapFirebaseAuthException(e));
    } on TypeError catch (_) {
      return const Result.failure(DataLayerError.mappingError());
    } on FormatException catch (_) {
      return const Result.failure(DataLayerError.mappingError());
    } catch (e) {
      debugPrint(e.toString());
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
      return Result.failure(mapFirebaseAuthException(e));
    } on TypeError catch (_) {
      return const Result.failure(DataLayerError.mappingError());
    } on FormatException catch (_) {
      return const Result.failure(DataLayerError.mappingError());
    } catch (e) {
      return Result.failure(DataLayerError.unknownError(e));
    }
  }

  @override
  Future<prefix.Result<List<Team>>> fetchTeamsPage({
    required int pageSize,
    required int pageIndex,
  }) async {
    try {
      final query = _teamsRef().limit(pageSize * (pageIndex + 1));

      final snapshot = await query.get();

      final docs = snapshot.docs.skip(pageSize * pageIndex).take(pageSize);

      final result = prefix.Result.ok(
        docs
            .map((doc) => Team.fromJson({...doc.data(), 'id': doc.id}))
            .toList(),
      );
			return result;
    } catch (e) {
			return prefix.Result.error(Exception(e));
		}
  }
}
