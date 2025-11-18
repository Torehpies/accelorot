import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/data/services/contracts/pagination_result.dart';
import 'package:flutter_application_1/data/services/contracts/pending_member_service.dart';

class FirebasePendingMemberService implements PendingMemberService {
  final FirebaseFirestore _firestore;
  FirebasePendingMemberService(this._firestore);

  @override
  Future<Map<String, dynamic>?> fetchRawPendingMemberData(String id) {
    // TODO: implement fetchRawPendingMemberData
    throw UnimplementedError();
  }

  @override
  Future<PaginationResult<Map<String, dynamic>>> fetchRawPendingMembers({
    required String teamId,
    required int limit,
    String? startCursor,
  }) async {
    Query query = _firestore
        .collection('teams')
        .doc(teamId)
        .collection('pending_members')
        .orderBy('requested_at', descending: true)
        .limit(limit);

    if (startCursor != null) {
      final lastDocSnapshot = await _firestore
          .collection('teams')
          .doc(teamId)
          .collection('pending_members')
          .doc(startCursor)
          .get();

      if (lastDocSnapshot.exists) {
        query = query.startAfterDocument(lastDocSnapshot);
      }
    }

    final snapshot = await query.get();

    final rawItems = snapshot.docs
        .map((doc) => doc.data())
        .toList()
        .cast<Map<String, dynamic>>();

    String? nextCursor;
    if (snapshot.docs.isNotEmpty && snapshot.docs.length == limit) {
      nextCursor = snapshot.docs.last.id;
    }

    return PaginationResult(items: rawItems, nextCursor: nextCursor);
  }
}
