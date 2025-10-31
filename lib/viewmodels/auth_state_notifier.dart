import 'dart:async';
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
  // Use userEntity for verification status, as it comes from Firestore
  bool get isVerified => userEntity?.emailVerified ?? false; 
  bool get isAdmin => userEntity?.isAdmin ?? false;
  bool get isRestricted => userEntity?.isRestricted ?? false;
  bool get isPendingApproval => userEntity?.pendingTeamId != null;
  bool get hasTeamId => userEntity?.teamId != null;

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

  // Use asyncExpand to switch streams: from FirebaseAuth to the UserEntity document
  return authRepository.authStateChanges.asyncExpand((firebaseUser) {
    if (firebaseUser == null) {
      // User is logged out. Emit unauthenticated state.
      return Stream.value(const AuthState.unauthenticated());
    }

    // User is logged in. Now, listen to their Firestore user document.
    // The inner stream (watchUserEntity) will emit whenever the user doc changes.
    // We use .map to transform the stream of UserEntity into a stream of AuthState.
    return userRepository.watchUserEntity(firebaseUser.uid).map((userEntity) {
      return AuthState(
        firebaseUser: firebaseUser,
        userEntity: userEntity,
        isInitialCheckDone: true,
      );
    }).handleError((e, stackTrace) {
      // *** FIX: Changed catchError to handleError, which is more reliable for Stream transformations ***
      log('Error in user entity stream: $e, $stackTrace');
      // If the user document fetch fails or errors, return a state with null entity
      // but keep the Firebase user logged in.
      return AuthState(
        firebaseUser: firebaseUser,
        userEntity: null,
        isInitialCheckDone: true,
      );
    });
  });
}

