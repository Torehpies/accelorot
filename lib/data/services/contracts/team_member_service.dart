import 'package:flutter_application_1/data/services/api/model/team_member/team_member.dart';

abstract class TeamMemberService {
	Future<List<TeamMember>> fetchTeamMembersPage({
		required String teamId,
		required int pageSize,
		required int pageIndex,
	});
}
