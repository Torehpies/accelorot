import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseTeamService {
  final FirebaseFirestore firestore;
  FirebaseTeamService(this.firestore);

  Future<Map<String, dynamic>?> fetchRawTeam(String teamId) async {
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

  Future<List<Map<String, dynamic>>> fetchRawPendingMembers(String teamId) async {
    final snapshot = await firestore
        .collection('teams')
        .doc(teamId)
        .collection('pending_members')
        .get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }
}
