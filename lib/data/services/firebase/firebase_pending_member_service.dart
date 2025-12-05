import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/data/models/app_user.dart';
import 'package:flutter_application_1/data/models/pending_member.dart';
import 'package:flutter_application_1/data/models/pending_member_user.dart';
import 'package:flutter_application_1/data/services/contracts/app_user_service.dart';
import 'package:flutter_application_1/data/services/contracts/data_layer_error.dart';
import 'package:flutter_application_1/data/services/contracts/pagination_result.dart';
import 'package:flutter_application_1/data/services/contracts/pending_member_service.dart';
import 'package:flutter_application_1/data/services/contracts/result.dart';
import 'package:flutter_application_1/data/utils/map_firebase_exception.dart';

class FirebasePendingMemberService implements PendingMemberService {
  final FirebaseFirestore _firestore;
  final AppUserService _userService;
  FirebasePendingMemberService(this._firestore, this._userService);

  @override
  Future<Map<String, dynamic>?> fetchRawPendingMemberData(String id) {
    // TODO: implement fetchRawPendingMemberData
    throw UnimplementedError();
  }

  //@override
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

  @override
  Future<String> addPendingMember({
    required String teamId,
    required String memberId,
    required String memberEmail,
  }) async {
    final docRef = _firestore
        .collection('teams')
        .doc(teamId)
        .collection('pending_members')
        .doc(memberId);

    final rawData = {
      'requestedAt': FieldValue.serverTimestamp(),
      'requestorId': memberId,
      'requestorEmail': memberEmail,
    };

    await docRef.set(rawData);

    return memberId;
  }

  @override
  Future<void> deletePendingMember({
    required String teamId,
    required String memberId,
  }) async {
    final docRef = _firestore
        .collection('teams')
        .doc(teamId)
        .collection('pending_members')
        .doc(memberId);

    await docRef.delete();
  }

  @override
  Future<void> processAcceptanceTransaction({
    required String teamId,
    required String memberId,
    required String email,
    required String firstName,
    required String lastName,
  }) async {
    final batch = _firestore.batch();

    final pendingRef = _firestore
        .collection('teams')
        .doc(teamId)
        .collection('pending_members')
        .doc(memberId);

    batch.delete(pendingRef);

    final teamMemberRef = _firestore
        .collection('teams')
        .doc(teamId)
        .collection('members')
        .doc(memberId);

    batch.set(teamMemberRef, {
      'role': 'Operator',
      'addedAt': FieldValue.serverTimestamp(),
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
    });

    await batch.commit();
  }

  @override
  Future<Result<List<PendingMember>, DataLayerError>> fetchPendingMembers(
    String teamId,
  ) async {

    try {
      final snapshot = await _firestore
          .collection('teams')
          .doc(teamId)
          .collection('pending_members')
          .orderBy('requestedAt', descending: true)
          .get();


      final pendingMembers = <PendingMember>[];

      for (var doc in snapshot.docs) {

        try {
          final data = doc.data();

          // DEBUG requested_at
          final ts = data['requestedAt'];

          final requestedAt = (ts as Timestamp?)?.toDate();

          // DEBUG requestorId
          final userId = data['requestorId'];

          if (requestedAt == null || userId == null) {
            return const Result.failure(DataLayerError.mappingError());
          }

          // DEBUG user fetch

          final rawUser = await _userService.fetchRawUserData(userId);


          if (rawUser == null) {
            return const Result.failure(DataLayerError.mappingError());
          }

          // DEBUG AppUser model conversion
          final user = AppUser.fromJson(rawUser);

          final pendingMemberUser = PendingMemberUser(
            uid: userId,
            firstName: user.firstname,
            lastName: user.lastname,
            email: user.email,
          );

          pendingMembers.add(
            PendingMember(user: pendingMemberUser, requestedAt: requestedAt),
          );

        } catch (e) {
          return const Result.failure(DataLayerError.mappingError());
        }
      }

      return Result.success(pendingMembers);
    } on FirebaseException catch (e) {
      return Result.failure(mapFirebaseException(e));
    } catch (e) {
      return Result.failure(DataLayerError.unknownError(e));
    }
  }
}
