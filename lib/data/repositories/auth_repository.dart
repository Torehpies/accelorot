import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:flutter/foundation.dart';
import 'package:flutter_application_1/data/models/user.dart';
import 'package:flutter_application_1/data/repositories/user_repository.dart';
import 'package:flutter_application_1/data/services/contracts/auth_service.dart';
import 'package:flutter_application_1/data/services/contracts/data_layer_error.dart';
import 'package:flutter_application_1/data/services/contracts/pending_member_service.dart';
import 'package:flutter_application_1/data/services/contracts/result.dart';
import 'package:flutter_application_1/utils/user_status.dart';

abstract class AuthRepository {
  Stream<User?> get authStateChanges;
  User? get currentUser;
  Future<Result<void, DataLayerError>> signIn({
    required String email,
    required String password,
  });
  Future<Result<void, DataLayerError>> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String globalRole,
    required String teamId,
  });
  Future<Result<void, DataLayerError>> signOut();
  Future<Result<void, DataLayerError>> signInWithGoogle();
}

class AuthRepositoryImpl implements AuthRepository {
  final AuthService _authService;
  final UserRepository _userRepository;
  final PendingMemberService _pendingMemberService;
  final FirebaseAuth _firebaseAuth;

  User? _lastKnownUser;

  AuthRepositoryImpl(
    this._authService,
    this._userRepository,
    this._pendingMemberService,
    this._firebaseAuth,
  );

  @override
  Stream<User?> get authStateChanges {
    return _authService.onAuthStateChanged.asyncMap((uid) async {
      if (uid == null) {
        _lastKnownUser = null;
        return null;
      }

      try {
        final user = await _userRepository.getUser(uid);
        _lastKnownUser = user;
        return user;
      } catch (e) {
        debugPrint(
          'Auth Error: User authenticated but profile fetch failed: $e',
        );
        _lastKnownUser = null;
        return null;
      }
    });
  }

  @override
  User? get currentUser => _lastKnownUser;

  @override
  Future<Result<void, DataLayerError>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await _authService.signInWithEmail(email, password);
      return Result.success(null);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'wrong-password') {
        return const Result.failure(PermissionError());
      } else if (e.code == 'network-request-failed') {
        return const Result.failure(NetworkError());
      }
      return const Result.failure(PermissionError());
    } catch (e) {
      return const Result.failure(NetworkError());
    }
  }

  @override
  Future<Result<void, DataLayerError>> signOut() async {
    try {
      await _authService.signOut();
      return const Result.success(null);
    } catch (e) {
      return const Result.failure(NetworkError());
    }
  }

  @override
  Future<Result<void, DataLayerError>> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String globalRole,
    required String teamId,
  }) async {
    try {
      /// Signup through Firebase
      final uid = await _authService.signUp(email, password);

      /// Add user profile in firestore
      final profileResult = await _userRepository.createUserProfile(
        uid: uid,
        email: email,
        firstName: firstName,
        lastName: lastName,
        globalRole: globalRole,
        status: UserStatus.unverified.value,
      );

      if (profileResult.isFailure) {
        return profileResult;
      }

      /// Add request in pending members
      await _pendingMemberService.addPendingMember(
        teamId: teamId,
        memberId: uid,
        memberEmail: email,
      );

      return const Result.success(null);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        return const Result.failure(DataLayerError.userExistsError());
      }
      if (e.code == 'weak-password' || e.code == 'invalid-email') {
        return Result.failure(
          DataLayerError.validationError(
            message:
                'Invalid input. Please check your email and password strength.',
          ),
        );
      }
      return const Result.failure(DataLayerError.networkError());
    } catch (e) {
      debugPrint('Unexpected error during signup: $e');
      return Result.failure(DataLayerError.unknownError(e));
    }
  }

  @override
  Future<Result<void, DataLayerError>> signInWithGoogle() async {
    try {
      final GoogleAuthProvider googleProvider = GoogleAuthProvider();
      await _firebaseAuth.signInWithPopup(googleProvider);

      return Result.success(null);
    } on FirebaseAuthException catch (e) {
      //TODO proper code checking
      debugPrint(e.toString());
      return Result.failure(NetworkError());
    } catch (e) {
      return Result.failure(NetworkError());
    }
  }
}
