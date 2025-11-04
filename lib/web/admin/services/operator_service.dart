// lib/services/operator_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/operator_model.dart';
import '../models/pending_member_model.dart'; // Fixed: was pending_member_modal.dart

class OperatorService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUserId => _auth.currentUser?.uid;

  // Load all operators
  Future<List<OperatorModel>> loadOperators() async {
    if (currentUserId == null) {
      throw Exception('No user logged in');
    }

    final membersSnapshot = await _firestore
        .collection('teams')
        .doc(currentUserId)
        .collection('members')
        .orderBy('addedAt', descending: true)
        .get();

    final List<OperatorModel> operators = [];

    for (var doc in membersSnapshot.docs) {
      final data = doc.data();
      final userId = data['userId'] as String?;

      if (userId != null) {
        final userDoc = await _firestore.collection('users').doc(userId).get();

        if (userDoc.exists) {
          final userData = userDoc.data();
          operators.add(OperatorModel.fromFirestore(userId, data, userData));
        }
      }
    }

    return operators;
  }

  // Archive operator
  Future<void> archiveOperator(String operatorUid) async {
    if (currentUserId == null) {
      throw Exception('No user logged in');
    }

    await _firestore
        .collection('teams')
        .doc(currentUserId)
        .collection('members')
        .doc(operatorUid)
        .update({
      'isArchived': true,
      'archivedAt': FieldValue.serverTimestamp(),
    });
  }

  // Restore operator
  Future<void> restoreOperator(String operatorUid) async {
    if (currentUserId == null) {
      throw Exception('No user logged in');
    }

    await _firestore
        .collection('teams')
        .doc(currentUserId)
        .collection('members')
        .doc(operatorUid)
        .update({
      'isArchived': false,
      'archivedAt': FieldValue.delete(),
    });
  }

  // Remove operator permanently (mark as left)
  Future<void> removeOperatorPermanently(String operatorUid) async {
    if (currentUserId == null) {
      throw Exception('No user logged in');
    }

    await _firestore
        .collection('teams')
        .doc(currentUserId)
        .collection('members')
        .doc(operatorUid)
        .update({
      'hasLeft': true,
      'leftAt': FieldValue.serverTimestamp(),
      'isArchived': true,
      'archivedAt': FieldValue.serverTimestamp(),
    });
  }

  // Load pending members
  Future<List<PendingMemberModel>> loadPendingMembers() async {
    if (currentUserId == null) {
      throw Exception('No user logged in');
    }

    final snapshot = await _firestore
        .collection('teams')
        .doc(currentUserId)
        .collection('pending_members')
        .orderBy('requestedAt', descending: true)
        .get();

    final List<PendingMemberModel> members = [];

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final requestorId = data['requestorId'] as String?;

      if (requestorId != null) {
        final userDoc = await _firestore.collection('users').doc(requestorId).get();

        if (userDoc.exists) {
          final userData = userDoc.data();
          members.add(PendingMemberModel.fromFirestore(doc.id, data, userData));
        }
      }
    }

    return members;
  }

  // Accept pending member
  Future<void> acceptPendingMember(PendingMemberModel member) async {
    if (currentUserId == null) {
      throw Exception('No user logged in');
    }

    final batch = _firestore.batch();

    // Add to members
    final memberRef = _firestore
        .collection('teams')
        .doc(currentUserId)
        .collection('members')
        .doc(member.requestorId);

    batch.set(memberRef, {
      'userId': member.requestorId,
      'name': member.name,
      'email': member.email,
      'role': 'Operator',
      'addedAt': FieldValue.serverTimestamp(),
      'isArchived': false,
      'hasLeft': false,
    });

    // Update user
    final userRef = _firestore.collection('users').doc(member.requestorId);
    batch.update(userRef, {
      'teamId': currentUserId,
      'pendingTeamId': FieldValue.delete(),
    });

    // Delete pending member
    final pendingRef = _firestore
        .collection('teams')
        .doc(currentUserId)
        .collection('pending_members')
        .doc(member.id);
    batch.delete(pendingRef);

    await batch.commit();
  }

  // Decline pending member
  Future<void> declinePendingMember(PendingMemberModel member) async {
    if (currentUserId == null) {
      throw Exception('No user logged in');
    }

    final batch = _firestore.batch();

    // Update user
    final userRef = _firestore.collection('users').doc(member.requestorId);
    batch.update(userRef, {
      'pendingTeamId': FieldValue.delete(),
    });

    // Delete pending member
    final pendingRef = _firestore
        .collection('teams')
        .doc(currentUserId)
        .collection('pending_members')
        .doc(member.id);
    batch.delete(pendingRef);

    await batch.commit();
  }

  // Add new operator
  Future<void> addOperator({
    required String firstName,
    required String lastName,
    required String username,
    required String email,
    required String password,
  }) async {
    throw UnimplementedError('Operator creation not yet implemented');
  }
}