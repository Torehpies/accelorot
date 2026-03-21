import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/data/services/api/model/pending_member/pending_member.dart';
import 'package:flutter_application_1/data/services/contracts/pending_members_service.dart';
import 'package:flutter_application_1/data/utils/result.dart';
import 'package:flutter_application_1/ui/activity_logs/models/activity_common.dart';

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
    } catch (e) {
      debugPrint(e.toString());
      return Result.error(Exception(e.toString()));
    }
  }

  // ===== ACCEPT / DECLINE =====
  @override
  Future<Result<void>> acceptPendingMember({
    required String teamId,
    required PendingMember member,
  }) async {
    throw UnimplementedError('Copy your existing acceptPendingMember impl here');
  }

  // ===== ACCEPT / DECLINE =====
  @override
  Future<Result<void>> deletePendingMember({
    required String teamId,
    required String docId,
  }) async {
    throw UnimplementedError('Copy your existing deletePendingMember impl here');
  }

  // ===== HELPER: DECLINE FLOW =====
  @override
  Future<Result<void>> addPendingMember({
    required String teamId,
    required PendingMember pendingMember,
  }) async {
    throw UnimplementedError('Copy your existing addPendingMember impl here');
  }
}