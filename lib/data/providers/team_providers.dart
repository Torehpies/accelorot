import 'package:flutter_application_1/data/providers/core_providers.dart';
import 'package:flutter_application_1/data/repositories/team_repository.dart';
import 'package:flutter_application_1/data/services/contracts/team_service.dart';
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
	final teamService = ref.read(teamServiceProvider);
	return TeamRepositoryImpl(teamService);
}

