import 'package:flutter_application_1/data/services/contracts/pagination_result.dart';

abstract class PendingMemberService {
	Future<Map<String, dynamic>?> fetchRawPendingMemberData(String id);
	Future<PaginationResult<Map<String, dynamic>>> fetchRawPendingMembers({
		required String teamId,
		required int limit,
		String? startCursor,
	});
}
