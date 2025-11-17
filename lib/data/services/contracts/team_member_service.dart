import 'package:flutter_application_1/data/services/contracts/pagination_result.dart';

abstract class TeamMemberService {
  Future<Map<String, dynamic>?> fetchRawTeamMemberData(String id);
  Future<PaginationResult<Map<String, dynamic>?>> fetchRawTeamMembers({
    required int limit,
    String? startCursor,
  });
}
