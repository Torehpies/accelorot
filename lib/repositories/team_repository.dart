import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
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

  Future<String?> getPendingTeam(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      final pendingTeamSelection =
          userDoc.data()?['pendingTeamSelection'] as String?;
      return pendingTeamSelection;
    } catch (e) {
      log(e.toString());
      throw GetPendingTeamException(e.toString());
    }
  }

  Future<String?> getTeamId(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      final teamId =
          userDoc.data()?['teamId'] as String?;
      return teamId;
    } catch (e) {
      debugPrint(e.toString());
			throw GetTeamIdException(e.toString());
    }
  }

  Future<void> sendTeamJoinRequest(String userId, String teamId) async {
    try {
      final batch = _firestore.batch();

      // Add to pending_members subcollection
      final pendingRef = _firestore
          .collection('teams')
          .doc(teamId)
          .collection('pending_members')
          .doc(userId);

      final userDoc = await _firestore.collection('users').doc(userId).get();
      final email = userDoc.data()?['email'] as String? ?? '';

      batch.set(pendingRef, {
        'requestorId': userId,
        'requestorEmail': email,
        'requestedAt': FieldValue.serverTimestamp(),
      });

      // Set pendingTeamId in user document
      final userRef = _firestore.collection('users').doc(userId);
      // Use batch.update() instead of the separate await updatePendingTeam() call
      batch.update(userRef, {'pendingTeamSelection': teamId});

      await batch.commit();
    } catch (e) {
      debugPrint('userId: $userId | teamId: $teamId');
      debugPrint('Failed sending team join request.');
      throw SendTeamJoinRequestException(e.toString());
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
