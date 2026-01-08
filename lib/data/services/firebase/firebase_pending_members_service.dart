import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/data/services/api/model/pending_member/pending_member.dart';
import 'package:flutter_application_1/data/services/contracts/pending_members_service.dart';
import 'package:flutter_application_1/data/utils/result.dart';

class FirebasePendingMembersService implements PendingMembersService {
  final FirebaseFirestore _firestore;

  FirebasePendingMembersService(this._firestore);

  CollectionReference<Map<String, dynamic>> _pendingMembersRef(String teamId) {
    return _firestore
        .collection('teams')
        .doc(teamId)
        .collection('pending_members');
  }

  @override
  Future<Result> acceptPendingMember({
    required String teamId,
    required String docId,
  }) {
    // TODO: implement acceptPendingMember
    throw UnimplementedError();
  }

  @override
  Future<Result> addPendingMember({
    required String teamId,
    required PendingMember pendingMember,
  }) {
    // TODO: implement addPendingMember
    throw UnimplementedError();
  }

  @override
  Future<Result> declinePendingMember({
    required String teamId,
    required String docId,
  }) {
    // TODO: implement declinePendingMember
    throw UnimplementedError();
  }

  @override
  Future<Result<List<PendingMember>>> getPendingMembersPage({
    required String teamId,
    required int pageSize,
    required int pageIndex,
  }) async {
    try {
      final query = _pendingMembersRef(teamId)
          .orderBy('requestedAt', descending: true)
          .limit(pageSize * (pageIndex + 1));

      final snapshot = await query.get();

      final docs = snapshot.docs.skip(pageSize * pageIndex).take(pageSize);

      return Result.ok(
        docs
            .map(
              (doc) => PendingMember.fromJson({
                ...doc.data(),
                'id': doc.id,
                'email': doc.data()['requestorEmail'] ?? doc.data()['email'],
              }),
            )
            .toList(),
      );
    } on FirebaseException catch (e) {
      return Result.error(e);
    } catch (e) {
      return Result.error(Exception(e.toString()));
    }
  }
}
