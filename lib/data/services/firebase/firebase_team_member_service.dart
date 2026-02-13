import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/data/services/api/model/team_member/team_member.dart';
import 'package:flutter_application_1/data/services/contracts/data_layer_error.dart';
import 'package:flutter_application_1/data/services/contracts/result.dart';
import 'package:flutter_application_1/data/services/contracts/team_member_service.dart';
import 'package:flutter_application_1/data/utils/map_firebase_exception.dart';
import 'package:flutter_application_1/ui/activity_logs/models/activity_common.dart';

class FirebaseTeamMemberService extends TeamMemberService {
  final FirebaseFirestore _firestore;

  FirebaseTeamMemberService(this._firestore);

  CollectionReference<Map<String, dynamic>> _membersRef(String teamId) {
    return _firestore.collection('teams').doc(teamId).collection('members');
  }

  @override
  Future<List<TeamMember>> fetchTeamMembersPage({
    required String teamId,
    required int pageSize,
    required int pageIndex,
    DateFilterRange? dateFilter,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _membersRef(
        teamId,
      ).orderBy('addedAt', descending: true).limit(pageSize * (pageIndex + 1));

      if (dateFilter?.isActive == true) {
        query = query
            .where('addedAt', isGreaterThanOrEqualTo: dateFilter!.startDate)
            .where('addedAt', isLessThanOrEqualTo: dateFilter.endDate);
      }
      final snapshot = await query.get();

      final docs = snapshot.docs.skip(pageSize * pageIndex).take(pageSize);

      return docs
          .map((doc) => TeamMember.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      debugPrint(e.toString());
    }
    return [];
  }

  @override
  Future<Result<void, DataLayerError>> updateTeamMember({
    required TeamMember member,
    required String teamId,
  }) async {
    try {
      await _membersRef(teamId).doc(member.id).update({
        'firstName': member.firstName,
        'lastName': member.lastName,
        'status': member.status.value,
        'updatedAt': DateTime.now(),
      });

      return Result.success(null);
    } on FirebaseException catch (e) {
      return Result.failure(mapFirebaseAuthException(e));
    } catch (e) {
      return Result.failure(DataLayerError.unknownError(e));
    }
  }
}
