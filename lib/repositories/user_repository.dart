import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/models/user_entity.dart';

class UserRepository {
  final FirebaseFirestore _firestore;

  UserRepository(this._firestore);

  Future<UserEntity?> fetchUserStatus(String uid) async {
    final userDoc = await _firestore.collection('users').doc(uid).get();

    if (!userDoc.exists || userDoc.data() == null) {
      return null;
    }

    UserEntity user = UserEntity.fromUserRoot(uid, userDoc.data()!);

    if (user.teamId != null) {
      try {
        final memberDoc = await _firestore
            .collection('teams')
            .doc(user.teamId)
            .collection('members')
            .doc(uid)
            .get();

        if (memberDoc.exists && memberDoc.data() != null) {
          final memberData = memberDoc.data()!;
          final isArchived = memberData['isArchived'] ?? false;
          final hasLeft = memberData['hasLeft'] ?? false;

          user = user.copyWith(hasLeft: hasLeft, isArchived: isArchived);
        }
      } catch (e) {
        log('Error fetching member status for $uid: e');
      }
    }

    return user;
  }
}
