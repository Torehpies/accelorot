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
import 'package:flutter_application_1/utils/user_status.dart';

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
  Future<Result<void, DataLayerError>> addPendingMember({
    required String teamId,
    required String memberId,
    required String memberEmail,
    required String firstName,
    required String lastName,
  }) async {
    try {
      final docRef = _firestore
          .collection('teams')
          .doc(teamId)
          .collection('pending_members')
          .doc(memberId);

      final rawData = {
        'requestedAt': FieldValue.serverTimestamp(),
        'requestorId': memberId,
        'requestorEmail': memberEmail,
				'firstName': firstName,
				'lastName': lastName,
      };

      await docRef.set(rawData);

      return Result.success(null);
    } on FirebaseException catch (e) {
      return Result.failure(mapFirebaseAuthException(e));
    } catch (e) {
      return Result.failure(DataLayerError.unknownError(e));
    }
  }

  @override
  Future<void> deletePendingMember({
    required String teamId,
    required String memberId,
  }) async {
    try {
      final docRef = _firestore
          .collection('teams')
          .doc(teamId)
          .collection('pending_members')
          .doc(memberId);

      await docRef.delete();
    } catch (e) {
			throw Exception("Failed to delete pending member. $e");
		}
  }

  @override
  Future<Result<void, DataLayerError>> processAcceptanceTransaction({
    required String teamId,
    required PendingMember member,
  }) async {
    try {
      final user = member.user;

      if (user == null) return Result.failure(DataLayerError.userNullError());

      final batch = _firestore.batch();

      final uid = user.uid;

      final pendingRef = _firestore
          .collection('teams')
          .doc(teamId)
          .collection('pending_members')
          .doc(uid);

      batch.delete(pendingRef);

      final teamMemberRef = _firestore
          .collection('teams')
          .doc(teamId)
          .collection('members')
          .doc(uid);

      batch.set(teamMemberRef, {
        'teamRole': 'Operator',
				'status': UserStatus.active.value,
        'addedAt': FieldValue.serverTimestamp(),
        'email': member.user?.email,
        'firstName': member.user?.firstName,
        'lastName': member.user?.lastName,
      });

      final userRef = _firestore.collection("users").doc(uid);

      batch.set(userRef, {
        "status": UserStatus.active.value,
        "teamRole": "Operator",
        "teamId": teamId,
        "requestTeamId": FieldValue.delete(),
      }, SetOptions(merge: true));

      await batch.commit();
      return Result.success(null);
    } on FirebaseException catch (e) {
      return Result.failure(mapFirebaseAuthException(e));
    } catch (e) {
      return Result.failure(DataLayerError.unknownError());
    }
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
      return Result.failure(mapFirebaseAuthException(e));
    } catch (e) {
      return Result.failure(DataLayerError.unknownError(e));
    }
  }
}
