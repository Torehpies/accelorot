import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/repositories/user_repository.dart';
import 'package:flutter_application_1/services/auth_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository(FirebaseFirestore.instance);
});
