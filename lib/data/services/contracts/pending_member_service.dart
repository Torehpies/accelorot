import 'package:flutter_application_1/data/models/pending_member.dart';
import 'package:flutter_application_1/data/services/contracts/data_layer_error.dart';
import 'package:flutter_application_1/data/services/contracts/result.dart';

abstract class PendingMemberService {
	Future<String> addPendingMember({
		required String teamId,
		required String memberId,
		required String memberEmail
	});
	Future<Map<String, dynamic>?> fetchRawPendingMemberData(String id);
	//Future<PaginationResult<Map<String, dynamic>>> fetchRawPendingMembers({
	//	required String teamId,
	//	required int limit,
	//	String? startCursor,
	//});
	Future<Result<List<PendingMember>,DataLayerError>> fetchPendingMembers(String teamId);
	Future<void> deletePendingMember({
		required String teamId,
		required String memberId,
	});
	Future<void> processAcceptanceTransaction({
		required String teamId,
		required String memberId,
		required String email,
		required String firstName,
		required String lastName,
	});
}
