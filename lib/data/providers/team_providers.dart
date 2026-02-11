import 'package:flutter_application_1/data/providers/app_user_providers.dart';
import 'package:flutter_application_1/data/providers/auth_providers.dart';
import 'package:flutter_application_1/data/providers/core_providers.dart';
import 'package:flutter_application_1/data/providers/pending_member_providers.dart';
import 'package:flutter_application_1/data/repositories/team_management/team_repository.dart';
import 'package:flutter_application_1/data/repositories/team_management/team_repository_remote.dart';
import 'package:flutter_application_1/data/services/api/model/team/team.dart';
import 'package:flutter_application_1/data/services/contracts/pending_members_service.dart';
import 'package:flutter_application_1/data/services/contracts/team_member_service.dart';
import 'package:flutter_application_1/data/services/contracts/team_service.dart';
import 'package:flutter_application_1/data/services/firebase/firebase_pending_members_service.dart';
import 'package:flutter_application_1/data/services/firebase/firebase_team_member_service.dart';
import 'package:flutter_application_1/data/services/firebase/firebase_team_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'team_providers.g.dart';

@Riverpod(keepAlive: true)
TeamService teamService(Ref ref) {
  final firestore = ref.read(firebaseFirestoreProvider);
  return FirebaseTeamService(firestore);
}

@Riverpod(keepAlive: true)
TeamRepository teamRepository(Ref ref) {
  return TeamRepositoryRemote(
    ref.read(teamServiceProvider),
    ref.read(pendingMemberServiceProvider),
    ref.read(appUserServiceProvider),
  );
}

@Riverpod(keepAlive: true)
TeamMemberService teamMemberService(Ref ref) {
  return FirebaseTeamMemberService(ref.read(firebaseFirestoreProvider));
}

@Riverpod(keepAlive: true)
PendingMembersService pendingMembersService(Ref ref) {
  return FirebasePendingMembersService(ref.read(firebaseFirestoreProvider));
}

@riverpod
Future<Team> currentTeam(Ref ref) async {
  final teamUser = ref.watch(appUserProvider).value;
  final teamId = teamUser?.teamId;
  return ref.read(teamServiceProvider).getTeam(teamId!);
}

@riverpod
Future<Team> requestTeam(Ref ref) async {
  final teamUser = ref.watch(appUserProvider).value;
  final teamId = teamUser?.requestTeamId;
  return ref.read(teamServiceProvider).getTeam(teamId!);
}
// Stream provider to reactively get current user's teamId
@riverpod
Stream<String?> currentUserTeamId(Ref ref) async* {
  await for (final user in ref.watch(appUserProvider.future).asStream()) {
    yield user?.teamId;
  }
}
