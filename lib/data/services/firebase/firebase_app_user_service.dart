import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_application_1/data/services/contracts/app_user_service.dart';
import 'package:flutter_application_1/data/services/contracts/data_layer_error.dart';
import 'package:flutter_application_1/data/services/contracts/result.dart';
import 'package:flutter_application_1/data/utils/map_firebase_exception.dart';

class FirebaseAppUserService implements AppUserService {
  final FirebaseFirestore _firestore;
  FirebaseAppUserService(this._firestore);

  @override
  Future<Map<String, dynamic>?> fetchRawUserData(String id) async {
    final snapshot = await _firestore.collection('users').doc(id).get();

    return snapshot.data();
  }

  @override
  Stream<DocumentSnapshot<Map<String, dynamic>>> watchRawUserData(String id) {
    final result = _firestore.collection('users').doc(id).snapshots();
    return result;
  }

  @override
  Future<Result<void, DataLayerError>> updateUserField(
    String uid,
    Map<String, dynamic> data,
  ) async {
    try {
      await _firestore.collection('users').doc(uid).update(data);
      return Result.success(null);
    } on FirebaseException catch (e) {
			print("DEBUG: update user field, firebase exception");
			print(e.toString());
      return Result.failure(mapFirebaseException(e));
    } catch (e) {
			print("DEBUG: update user field, unknown error");
      return Result.failure(DataLayerError.unknownError(e));
    }
  }
}
