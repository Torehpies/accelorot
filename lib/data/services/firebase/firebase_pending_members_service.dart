import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/data/services/api/model/pending_member/pending_member.dart';
import 'package:flutter_application_1/data/services/contracts/pending_members_service.dart';
import 'package:flutter_application_1/data/utils/result.dart';
import 'package:flutter_application_1/ui/activity_logs/models/activity_common.dart';
import 'package:flutter_application_1/utils/user_status.dart';

class FirebasePendingMembersService extends PendingMembersService {
  final FirebaseFirestore _firestore;

  FirebasePendingMembersService(this._firestore);

  CollectionReference<Map<String, dynamic>> _pendingRef(String teamId) {
    return _firestore
        .collection('teams')
        .doc(teamId)
        .collection('pending_members');
  }

  // ===== FETCH PAGE (kept for PendingMembersNotifier backwards compat) =====
  @override
  Future<Result<List<PendingMember>>> getPendingMembersPage({
    required String teamId,
    required int pageSize,
    required int pageIndex,
    DateFilterRange? dateFilter,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _pendingRef(teamId)
          .orderBy('requestedAt', descending: true)
          .limit(pageSize * (pageIndex + 1));

      if (dateFilter?.isActive == true) {
        query = query
            .where('requestedAt', isGreaterThanOrEqualTo: dateFilter!.startDate)
            .where('requestedAt', isLessThanOrEqualTo: dateFilter.endDate);
      }

      final snapshot = await query.get();
      final docs = snapshot.docs.skip(pageSize * pageIndex).take(pageSize);

      return Result.ok(
        docs.map((doc) {
          final data = doc.data();
          return PendingMember.fromJson({
            ...data,
            'id': doc.id,
            'email': data['requestorEmail'] ?? '',
          });
        }).toList(),
      );
    } on FirebaseException catch (e) {
      return Result.error(e);
    } catch (e) {
      debugPrint(e.toString());
      return Result.error(Exception(e.toString()));
    }
  }

  // ===== FETCH ALL (used by PendingMembersNotifier for client-side pagination) =====
  @override
  Future<Result<List<PendingMember>>> getAllPendingMembers({
    required String teamId,
    DateFilterRange? dateFilter,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _pendingRef(teamId)
          .orderBy('requestedAt', descending: true);

      if (dateFilter?.isActive == true) {
        query = query
            .where('requestedAt', isGreaterThanOrEqualTo: dateFilter!.startDate)
            .where('requestedAt', isLessThanOrEqualTo: dateFilter.endDate);
      }

      final snapshot = await query.get();

      return Result.ok(
        snapshot.docs.map((doc) {
          final data = doc.data();
          return PendingMember.fromJson({
            ...data,
            'id': doc.id,
            'email': data['requestorEmail'] ?? '',
          });
        }).toList(),
      );
    } on FirebaseException catch (e) {
      return Result.error(e);
    } catch (e) {
      debugPrint(e.toString());
      return Result.error(Exception(e.toString()));
    }
  }

  // ===== ACCEPT / DECLINE =====
  @override
  Future<Result> acceptPendingMember({
    required String teamId,
    required PendingMember member,
  }) async {
    try {
      final batch = _firestore.batch();

      final uid = member.id;

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
        'email': member.email,
        'firstName': member.firstName,
        'lastName': member.lastName,
      });

      final userRef = _firestore.collection("users").doc(uid);

      batch.set(userRef, {
        "status": UserStatus.active.value,
        "teamRole": "Operator",
        "teamId": teamId,
        "requestTeamId": FieldValue.delete(),
      }, SetOptions(merge: true));

      await batch.commit();
      return Result.ok(null);
    } on FirebaseException catch (e) {
      return Result.error(e);
    } catch (e) {
      return Result.error(Exception(e));
    }
  }

  @override
  Future<Result> addPendingMember({
    required String teamId,
    required PendingMember pendingMember,
  }) {
    // TODO: implement addPendingMember
    throw UnimplementedError();
  }

  /// Decline request to join
  @override
  Future<Result> deletePendingMember({
    required String teamId,
    required String docId,
  }) async {
    try {
      final docRef = _firestore
          .collection('teams')
          .doc(teamId)
          .collection('pending_members')
          .doc(docId);

      await docRef.delete();
      return Result.ok(null);
    } on FirebaseException catch (e) {
      return Result.error(e);
    } catch (e) {
      debugPrint(e.toString());
      return Result.error(Exception(e.toString()));
    }
  }
}