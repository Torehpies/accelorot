import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/models/user_entity.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'user_repository.g.dart';

@Riverpod(keepAlive: true)
UserRepository userRepository(Ref ref) {
  return UserRepository(FirebaseFirestore.instance);
}

class UserRepository {
  final FirebaseFirestore _firestore;

  UserRepository(this._firestore);

  Future<UserEntity> fetchUserEntity(String uid) async {
    try {
      final docSnapshot = await _firestore.collection('users').doc(uid).get();

      if (!docSnapshot.exists) {
        throw Exception('User profile not found in Firestore for UID: $uid');
      }

			return UserEntity.fromMap(uid, docSnapshot.data()!);
    } on FirebaseException catch (e) {
      throw Exception('Firebase fetch error: ${e.message} (Code: ${e.code})');
    } catch (e) {
      throw Exception(
        'An unexpected error occurred while fetching user profile.',
      );
    }
  }
}
