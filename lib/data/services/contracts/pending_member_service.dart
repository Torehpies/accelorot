import 'package:flutter_application_1/data/services/contracts/pagination_result.dart';

abstract class PendingMemberService {
	Future<String> addPendingMember({
		required String teamId,
		required String memberId,
		required String memberEmail
	});
	Future<Map<String, dynamic>?> fetchRawPendingMemberData(String id);
	Future<PaginationResult<Map<String, dynamic>>> fetchRawPendingMembers({
		required String teamId,
		required int limit,
		String? startCursor,
	});
	Future<void> deletePendingMember({
		required String teamId,
		required String memberId,
	});
}
