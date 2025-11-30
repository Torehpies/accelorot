import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/data/services/contracts/team_service.dart';

class FirebaseTeamService implements TeamService {
  final FirebaseFirestore firestore;
  FirebaseTeamService(this.firestore);

  @override
  Future<Map<String, dynamic>?> fetchRawTeamData(String teamId) async {
    final snapshot = await firestore.collection('teams').doc(teamId).get();
    return snapshot.data();
  }

  Future<List<Map<String, dynamic>>> fetchRawTeamMembers(String teamId) async {
    final snapshot = await firestore
        .collection('teams')
        .doc(teamId)
        .collection('members')
        .get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  Future<List<Map<String, dynamic>>> fetchRawPendingMembers(
    String teamId,
  ) async {
    final snapshot = await firestore
        .collection('teams')
        .doc(teamId)
        .collection('pending_members')
        .get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  @override
  Future<QuerySnapshot<Map<String, dynamic>?>> fetchRawTeams() async {
		return firestore.collection('teams').get();
  }

  @override
  Future<void> addTeam(
    String teamName,
    String address,
    String createdBy,
  ) async {
    final data = {
      "teamName": teamName,
      "address": address,
      "createdAt": FieldValue.serverTimestamp(),
      "createdBy": createdBy,
    };
    await firestore.collection('teams').add(data);
  }
}
