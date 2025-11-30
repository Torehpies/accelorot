abstract class TeamService {
  Future<Map<String, dynamic>?> fetchRawTeamData(String id);
  Future<List<Map<String, dynamic>?>> fetchRawTeams();
  Future<void> addTeam(String teamName, String address, String createdBy);
}
