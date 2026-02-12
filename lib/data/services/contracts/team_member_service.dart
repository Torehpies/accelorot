import 'package:flutter_application_1/data/services/api/model/team_member/team_member.dart';
import 'package:flutter_application_1/data/services/contracts/data_layer_error.dart';
import 'package:flutter_application_1/data/services/contracts/result.dart';
import 'package:flutter_application_1/ui/activity_logs/models/activity_common.dart';

abstract class TeamMemberService {
  Future<List<TeamMember>> fetchTeamMembersPage({
    required String teamId,
    required int pageSize,
    required int pageIndex,
    DateFilterRange? dateFilter,
  });
  Future<Result<void, DataLayerError>> updateTeamMember({
    required TeamMember member,
    required String teamId,
  });
}
