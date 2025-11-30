import 'package:flutter/foundation.dart';
import 'package:flutter_application_1/data/models/user.dart';
import 'package:flutter_application_1/data/providers/core_providers.dart';
import 'package:flutter_application_1/data/providers/pending_members_providers.dart';
import 'package:flutter_application_1/data/providers/user_providers.dart';
import 'package:flutter_application_1/data/repositories/auth_repository.dart';
import 'package:flutter_application_1/data/services/contracts/auth_service.dart';
import 'package:flutter_application_1/data/services/firebase/firebase_auth_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_providers.g.dart';

@Riverpod(keepAlive: true)
AuthService authService(Ref ref) {
  final firebaseAuth = ref.read(firebaseAuthProvider);
  return FirebaseAuthService(firebaseAuth);
}

@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) {
  final authService = ref.read(authServiceProvider);
  final userRepository = ref.read(userRepositoryProvider);
  final pendingMemberService = ref.read(pendingMemberServiceProvider);
  final firebaseAuth = ref.read(firebaseAuthProvider);

  return AuthRepositoryImpl(
    authService,
    userRepository,
    pendingMemberService,
    firebaseAuth,
  );
}

@Riverpod(keepAlive: true)
Stream<User?> authState(Ref ref) {
  final repository = ref.watch(authRepositoryProvider);
  return repository.authStateChanges;
}

@Riverpod(keepAlive: true)
Stream<User?> userProfile(Ref ref) {
  final userService = ref.watch(userServiceProvider);
  final authUser = ref.watch(authStateChangesProvider).value;

  if (authUser == null) return const Stream.empty();

  final rawData = userService.watchRawUserData(authUser.uid);
  return rawData.map((doc) {
    final data = doc.data();
    if (data == null) return null;

    final user = User.fromJson({...data});
		return user;
  });
}
