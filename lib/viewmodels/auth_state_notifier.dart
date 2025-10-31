import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/models/user_entity.dart';
import 'package:flutter_application_1/repositories/auth_repository.dart';
import 'package:flutter_application_1/repositories/user_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_state_notifier.g.dart';

class AuthState {
  final User? firebaseUser;
  final UserEntity? userEntity;
  final bool isInitialCheckDone;

  const AuthState({
    required this.firebaseUser,
    required this.userEntity,
    this.isInitialCheckDone = false,
  });

  bool get isAuthenticated => firebaseUser != null && userEntity != null;
  bool get isVerified => firebaseUser?.emailVerified ?? false;
  bool get isAdmin => userEntity?.isAdmin ?? false;
  bool get isRestricted => userEntity?.isRestricted ?? false;
  bool get isPendingApproval => userEntity?.pendingTeamId != null;

  const AuthState.unauthenticated({this.isInitialCheckDone = true})
    : firebaseUser = null,
      userEntity = null;
  const AuthState.checking()
    : firebaseUser = null,
      userEntity = null,
      isInitialCheckDone = false;
}

@Riverpod(keepAlive: true)
Stream<AuthState> authState(Ref ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  final userRepository = ref.watch(userRepositoryProvider);

  return authRepository.authStateChanges.asyncMap((firebaseUser) async {
    if (firebaseUser == null) {
      return const AuthState.unauthenticated();
    }

		try {
			final userEntity = await userRepository.fetchUserEntity(firebaseUser.uid);
			return AuthState(firebaseUser: firebaseUser, userEntity: userEntity, isInitialCheckDone: true);
		} catch (e) {
			log('Error fetching UserEntity for $firebaseUser.uid: $e. Redirecting to profile completion.');
			return AuthState(firebaseUser: firebaseUser, userEntity: null, isInitialCheckDone: true);
		}
  }).handleError((e, st) {
			log('Auth Stream Fatal Error: $e');
			return const AuthState.unauthenticated();
		});
}
