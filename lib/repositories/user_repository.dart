import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/models/user.dart';
import 'package:flutter_application_1/services/firebase_user_service.dart';

abstract class UserRepository {
  Future<User> getUser(String id);
}

class UserRepositoryImpl implements UserRepository {
  final FirebaseUserService userService;

  UserRepositoryImpl(this.userService);

  User _mapRawDataToDomain(Map<String, dynamic> rawData) {
    final Timestamp timestamp = rawData['createdAt'] as Timestamp;
    final cleanMap = Map<String, dynamic>.from(rawData);
    cleanMap['createdAt'] = timestamp.toDate();
    return User.fromJson(cleanMap);
  }

  @override
  Future<User> getUser(String id) async {
    final rawData = await userService.fetchRawUserData(id);
    if (rawData == null) {
      throw Exception('User data not found.');
    }

		return _mapRawDataToDomain(rawData);
  }
}
