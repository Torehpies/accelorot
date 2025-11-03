import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/repositories/auth_repository.dart';
import 'package:flutter_application_1/utils/app_exceptions.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'team_repository.g.dart';

class Team {
  final String id;
  final String name;

  Team({required this.id, required this.name});
}

class TeamRepository {
  final FirebaseFirestore _firestore;

  TeamRepository(this._firestore);

  Future<List<Team>> fetchAllTeams() async {
    final teamSnapshot = await _firestore.collection('teams').get();

    return teamSnapshot.docs.map((doc) {
      final data = doc.data();
      return Team(id: doc.id, name: data['teamName'] ?? 'Unnamed Team');
    }).toList();
  }

  Future<void> updatePendingTeam(String userId, String teamId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'pendingTeamSelection': teamId,
      });
    } catch (e) {
			log(e.toString());
      throw UpdatePendingTeamException(e.toString());
    }
  }
}

@Riverpod(keepAlive: true)
TeamRepository teamRepository(Ref ref) {
  return TeamRepository(ref.watch(firebaseFirestoreProvider));
}

@riverpod
Future<List<Team>> teamList(Ref ref) {
	final teamRepo = ref.watch(teamRepositoryProvider);
	return teamRepo.fetchAllTeams();
}
