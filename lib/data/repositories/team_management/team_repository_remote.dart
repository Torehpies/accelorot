import 'package:flutter_application_1/data/repositories/team_management/team_repository.dart';
import 'package:flutter_application_1/data/services/api/model/team/team.dart';
import 'package:flutter_application_1/data/services/contracts/app_user_service.dart';
import 'package:flutter_application_1/data/services/contracts/data_layer_error.dart';
import 'package:flutter_application_1/data/services/contracts/pending_member_service.dart';
import 'package:flutter_application_1/data/services/contracts/result.dart';
import 'package:flutter_application_1/data/services/contracts/team_service.dart';
import 'package:flutter_application_1/utils/user_status.dart';

class TeamRepositoryRemote implements TeamRepository {
  TeamRepositoryRemote(
    this._teamService,
    this._pendingMemberService,
    this._appUserService,
  );

  final TeamService _teamService;
  final PendingMemberService _pendingMemberService;
  final AppUserService _appUserService;
  List<Team>? _cachedTeams;

  @override
  Future<Result<Team, DataLayerError>> addTeam(Team team) async {
    final result = await _teamService.addTeam(team);

    result.when(
      success: (team) => _cachedTeams?.add(team),
      failure: (_) => _cachedTeams,
    );

    return result;
  }

  @override
  Future<Result<List<Team>, DataLayerError>> getTeams({
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && _cachedTeams != null) {
      return Result.success(_cachedTeams!);
    }

    final result = await _teamService.getTeams();

    result.when(
      success: (teams) => _cachedTeams = teams,
      failure: (_) => _cachedTeams,
    );

    return result;
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
  ) async {
    final addRequestResult = await _pendingMemberService.addPendingMember(
      teamId: teamId,
      memberId: userId,
      memberEmail: email,
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

		final isInTeam = appUser.teamId.isNotEmpty;
		return Result.success(isInTeam);
  }
}
