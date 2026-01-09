// Initial Pending Member Service
// Can't be deleted or merge with new pending_members_service.dart
// as many reference this old service.
import 'package:flutter_application_1/data/models/pending_member.dart';
import 'package:flutter_application_1/data/services/contracts/data_layer_error.dart';
import 'package:flutter_application_1/data/services/contracts/result.dart';

abstract class PendingMemberService {
	Future<Result<void, DataLayerError>> addPendingMember({
		required String teamId,
		required String memberId,
		required String memberEmail,
    required String firstName,
    required String lastName,
	});
	Future<Map<String, dynamic>?> fetchRawPendingMemberData(String id);
	Future<Result<List<PendingMember>,DataLayerError>> fetchPendingMembers(String teamId);
	Future<void> deletePendingMember({
		required String teamId,
		required String memberId,
	});
	Future<Result<void, DataLayerError>> processAcceptanceTransaction({
		required String teamId,
		required PendingMember member,
	});
}
