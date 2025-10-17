//import 'package:firebase_auth/firebase_auth.dart';
//import 'package:flutter_application_1/data/repositories/auth_repository.dart';
//import 'package:flutter_application_1/data/repositories/firebase_auth_repository.dart';
//import 'package:flutter_application_1/data/services/firebase_auth_service.dart';
//import 'package:flutter_riverpod/flutter_riverpod.dart';

//final firebaseAuthServiceProvider = Provider<FirebaseAuthService>((ref) {
//  return FirebaseAuthService();
//});
//
//final firebaseAuthRepositoryProvider = Provider<FirebaseAuthRepository>((ref) {
//  final service = ref.watch(firebaseAuthServiceProvider);
//  return FirebaseAuthRepository(service);
//});
//
//final authStateProvider = StreamProvider<User?>(isAutoDispose: false, (ref) {
//  // print('authStateChangesProvider initialized');
//  final repository = ref.watch(firebaseAuthRepositoryProvider);
//  return repository.idTokenChanges.map((user) {
//    // print('[AuthStateProvider] user: ${user?.uid}');
//    return user;
//  });
//});

