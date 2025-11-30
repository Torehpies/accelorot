import 'package:cloud_firestore/cloud_firestore.dart';

abstract class TeamService {
  Future<Map<String, dynamic>?> fetchRawTeamData(String id);
  Future<QuerySnapshot<Map<String, dynamic>?>> fetchRawTeams();
  Future<void> addTeam(String teamName, String address, String createdBy);
}
