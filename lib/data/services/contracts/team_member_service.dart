import 'package:flutter_application_1/data/services/api/model/team_member/team_member.dart';
import 'package:flutter_application_1/ui/activity_logs/models/activity_common.dart';

abstract class TeamMemberService {
  Future<List<TeamMember>> fetchTeamMembersPage({
    required String teamId,
    required int pageSize,
    required int pageIndex,
		DateFilterRange? dateFilter,
  });
  Future<void> updateTeamMember({
    required TeamMember member,
    required String teamId,
  });
}
