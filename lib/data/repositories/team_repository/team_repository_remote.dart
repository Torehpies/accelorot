import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/data/repositories/team_repository/team_repository.dart';
import 'package:flutter_application_1/data/utils/result.dart' as result;
import 'package:flutter_application_1/data/services/api/model/team/team.dart';
import 'package:flutter_application_1/data/services/contracts/app_user_service.dart';
import 'package:flutter_application_1/data/services/contracts/data_layer_error.dart';
import 'package:flutter_application_1/data/services/contracts/pending_member_service.dart';
import 'package:flutter_application_1/data/services/contracts/result.dart';
import 'package:flutter_application_1/data/services/contracts/team_service.dart';
import 'package:flutter_application_1/utils/operator_headers.dart';
import 'package:flutter_application_1/utils/user_status.dart';

class TeamRepositoryRemote implements TeamRepository {
  TeamRepositoryRemote(
    this._teamService,
    this._pendingMemberService,
    this._appUserService,
    this._firestore,
  );

  final FirebaseFirestore _firestore;
  final TeamService _teamService;
  final PendingMemberService _pendingMemberService;
  final AppUserService _appUserService;
  List<Team>? _cachedTeams;

  @override
  Future<Team> addTeam(Team team) async {
    try {
      final docRef = _firestore.collection('teams').doc();
      final updatedTeam = team.copyWith(teamId: docRef.id);
      await docRef.set(updatedTeam.toJson());
      return updatedTeam;
    } on FirebaseException catch (e) {
      log('Failed to add team: $e');
      rethrow;
    } catch (e) {
      log('Failed to add team: $e');
      rethrow;
    }
  }

  @override
  Future<List<Team>> getTeams({bool forceRefresh = false}) async {
    if (!forceRefresh && _cachedTeams != null) {
      return _cachedTeams!;
    }

    final result = await _teamService.getTeams();

    return result.when(
      success: (teams) {
        _cachedTeams = teams;
        return teams;
      },
      failure: (_) => _cachedTeams ?? <Team>[],
    );
  }

  @override
  void clearCache() {
    _cachedTeams = null;
  }

  @override
  Future<Result<void, DataLayerError>> requestToJoinTeam(
    String teamId,
    String userId,
    String email,
    String firstName,
    String lastName,
  ) async {
    final addRequestResult = await _pendingMemberService.addPendingMember(
      teamId: teamId,
      memberId: userId,
      memberEmail: email,
      firstName: firstName,
      lastName: lastName,
    );

    if (addRequestResult.isFailure) {
      return Result.failure(addRequestResult.asFailure);
    }

    final data = {"status": UserStatus.pending.value, "requestTeamId": teamId};

    final updateUserResult = await _appUserService.updateUserField(
      userId,
      data,
    );

    if (updateUserResult.isFailure) {
      return Result.failure(updateUserResult.asFailure);
    }

    final teamResult = await _teamService.incrementTeamField(
      teamId: teamId,
      field: OperatorHeaders.pendingOperators,
      amount: 1,
    );

    if (teamResult is result.Error<String>) {
      return Result.failure(teamResult.error as DataLayerError);
    }
    return Result.success(null);
  }

  @override
  Future<Result<bool, DataLayerError>> isInTeam(String userId) async {
    final getUserResult = await _appUserService.getAppUserAsync(userId);
    if (getUserResult.isFailure) {
      return Result.failure(getUserResult.asFailure);
    }
    final appUser = getUserResult.asSuccess;

    if (appUser == null) {
      return Result.failure(DataLayerError.userNullError());
    }

    final isInTeam = appUser.teamId!.isNotEmpty;
    return Result.success(isInTeam);
  }
}
