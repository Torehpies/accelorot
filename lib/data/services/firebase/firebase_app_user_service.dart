import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/data/models/app_user.dart';
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
  Future<Result<void, DataLayerError>> updateUserField(
    String uid,
    Map<String, dynamic> data,
  ) async {
    try {
      await _firestore.collection('users').doc(uid).update(data);
      return Result.success(null);
    } on FirebaseException catch (e) {
      return Result.failure(mapFirebaseException(e));
    } catch (e) {
      return Result.failure(DataLayerError.unknownError(e));
    }
  }

  @override
  Stream<AppUser?> getAppUser(String id) {
    try {
      return _firestore.collection('users').doc(id).snapshots().map((doc) {
        if (!doc.exists || doc.data() == null) return null;
        return AppUser.fromJson(doc.data()!);
      });
    } catch (e) {
      return Stream.error(DataLayerError.databaseError(message: e.toString()));
    }
  }

  @override
  Future<Result<AppUser?, DataLayerError>> getAppUserAsync(String id) async {
    try {
      final doc = await _firestore.collection('users').doc(id).get();
      if (!doc.exists || doc.data() == null) {
        return Result.failure(DataLayerError.userNullError());
      }
      return Result.success(AppUser.fromJson(doc.data()!));
    } on FirebaseException catch (e) {
      return Result.failure(mapFirebaseException(e));
    } catch (e) {
      return Result.failure(DataLayerError.unknownError(e));
    }
  }
}
