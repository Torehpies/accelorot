import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/data/services/api/model/team_member/team_member.dart';
import 'package:flutter_application_1/data/services/contracts/team_member_service.dart';

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
  }) async {
    try {
      final query = _membersRef(
        teamId,
      ).orderBy('addedAt', descending: true).limit(pageSize * (pageIndex + 1));

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
  Future<void> updateTeamMember({
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
    } on FirebaseException catch (e) {
      debugPrint(e.toString());
    } catch (e) {
      debugPrint(e.toString());
		}
  }
}
