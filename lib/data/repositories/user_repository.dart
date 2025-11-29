import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_application_1/data/models/user.dart';
import 'package:flutter_application_1/data/services/contracts/auth_service.dart';
import 'package:flutter_application_1/data/services/contracts/data_layer_error.dart';
import 'package:flutter_application_1/data/services/contracts/result.dart';
import 'package:flutter_application_1/data/services/contracts/user_service.dart';

abstract class UserRepository {
  Future<Result<User, DataLayerError>> getUser(String id);
  Future<Result<void, DataLayerError>> createUserProfile({
    required String uid,
    required String email,
    required String firstName,
    required String lastName,
    required String globalRole,
    required String status,
  });
  User mapRawDataToDomain(Map<String, dynamic> rawData);
}

class UserRepositoryImpl implements UserRepository {
  final UserService userService;
  final AuthService authService;
  final FirebaseFirestore firestore;

  UserRepositoryImpl(this.userService, this.authService, this.firestore);

  @override
  User mapRawDataToDomain(Map<String, dynamic> rawData) {
    final Timestamp timestamp = rawData['createdAt'] as Timestamp;
    final cleanMap = Map<String, dynamic>.from(rawData);
    cleanMap['createdAt'] = timestamp.toDate();
    return User.fromJson(cleanMap);
  }

  @override
  Future<Result<User, DataLayerError>> getUser(String id) async {
    try {
      final rawData = await userService.fetchRawUserData(id);
      if (rawData == null) {
        return Result.failure(DataLayerError.userExistsError());
      }

      return Result.success(mapRawDataToDomain(rawData));
    } catch (e) {
      return Result.failure(DataLayerError.unknownError(e.toString()));
    }
  }

  Future<User?> getUserModel(String id) async {
    try {
      final rawData = await userService.fetchRawUserData(id);
      if (rawData == null) {
        return null;
      }

      return mapRawDataToDomain(rawData);
    } catch (e) {
			return null;
    }
  }

  @override
  Future<Result<void, DataLayerError>> createUserProfile({
    required String uid,
    required String email,
    required String firstName,
    required String lastName,
    required String globalRole,
    required String status,
  }) async {
    try {
      await firestore.collection('users').doc(uid).set({
        'uid': uid,
        'email': email,
        'firstname': firstName,
        'lastname': lastName,
        'globalRole': globalRole,
        'createdAt': FieldValue.serverTimestamp(),
        'status': status,
      });
      return Result.success(null);
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        return const Result.failure(DataLayerError.permissionError());
      }
      return const Result.failure(DataLayerError.networkError());
    } catch (e) {
      debugPrint('Unexpected error on creating user profile: $e');
      return Result.failure(DataLayerError.unknownError(e));
    }
  }
}
