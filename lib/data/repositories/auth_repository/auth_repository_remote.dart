import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_application_1/data/models/app_user.dart';
import 'package:flutter_application_1/data/repositories/app_user_repository/app_user_repository.dart';
import 'package:flutter_application_1/data/services/contracts/app_user_service.dart';
import 'package:flutter_application_1/data/services/contracts/auth_service.dart';
import 'package:flutter_application_1/data/services/contracts/data_layer_error.dart';
import 'package:flutter_application_1/data/services/contracts/pending_member_service.dart';
import 'package:flutter_application_1/data/services/contracts/result.dart';
import 'package:flutter_application_1/data/repositories/auth_repository/auth_repository.dart';
import 'package:flutter_application_1/data/utils/map_firebase_exception.dart';
import 'package:flutter_application_1/utils/user_status.dart';

class AuthRepositoryRemote implements AuthRepository {
  final AuthService _authService;
  final AppUserRepository _userRepository;
  final PendingMemberService _pendingMemberService;
  final FirebaseAuth _firebaseAuth;
  final AppUserService _userService;

  AppUser? _lastKnownUser;

  AuthRepositoryRemote(
    this._authService,
    this._userRepository,
    this._pendingMemberService,
    this._firebaseAuth,
    this._userService,
  );

  @override
  Stream<AppUser?> get authStateChanges {
    return _authService.onAuthStateChanged.asyncMap((uid) async {
      if (uid == null) {
        _lastKnownUser = null;
        return null;
      }

      AppUser? fetchedUser;

      try {
        final result = await _userRepository.getUser(uid);

        result.when(
          success: (user) {
            _lastKnownUser = user;
            fetchedUser = user;
          },
          failure: (failure) {
            debugPrint(
              'Auth Error: User authenticated but profile fetch failed: $failure',
            );
            _lastKnownUser = null;
          },
        );
      } catch (e) {
        debugPrint(
          'Auth Error: User authenticated but profile fetch failed: $e',
        );
        _lastKnownUser = null;
        return null;
      }
      return fetchedUser;
    });
  }

  @override
  AppUser? get currentUser => _lastKnownUser;

  @override
  Future<Result<void, DataLayerError>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await _authService.signInWithEmail(email, password);
      return Result.success(null);
    } on FirebaseAuthException catch (e) {
      return Result.failure(mapFirebaseAuthException(e));
    } catch (e) {
      debugPrint("UNKNOWN ERROR");
      return Result.failure(DataLayerError.unknownError(e));
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
      final user = await _authService.signUp(email, password);

      await _authService.updateDisplayName(user, "$firstName $lastName");

      /// Add user profile in firestore
      final profileResult = await _userRepository.createUserProfile(
        uid: user.uid,
        email: email,
        firstName: firstName,
        lastName: lastName,
        globalRole: globalRole,
        status: UserStatus.pending.value,
        requestTeamId: teamId,
      );

      if (profileResult.isFailure) {
        return Result.failure(profileResult.asFailure);
      }

      /// Add request in pending members
      final pendingAdd = await _pendingMemberService.addPendingMember(
        teamId: teamId,
        memberId: user.uid,
        memberEmail: email,
      );

      if (pendingAdd.isFailure) return Result.failure(pendingAdd.asFailure);

      return const Result.success(null);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        return const Result.failure(DataLayerError.userExistsError());
      }
      if (e.code == 'weak-password' || e.code == 'invalid-email') {
        return Result.failure(
          DataLayerError.validationError(
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

  @override
  Future<Result<void, DataLayerError>> updateUserStatus(
    UserStatus status,
  ) async {
    try {
      final userId = _firebaseAuth.currentUser?.uid;
      final data = {'status': status};
      await _userService.updateUserField(userId!, data);
      return Result.success(null);
    } catch (e) {
      return Result.failure(DataLayerError.unknownError(e.toString()));
    }
  }

  @override
  Future<Result<void, DataLayerError>> syncEmailVerification(String uid) async {
    final result = await _authService.checkEmailVerified();

    return result.when(
      success: (isVerified) async {
        if (!isVerified) {
          return Result.failure(DataLayerError.emailNotVerifiedError());
        }

        await updateUserStatus(UserStatus.pending);
        debugPrint("Updating user status.");
        return Result.success(null);
      },
      failure: (error) => Result.failure(error),
    );
  }

  @override
  Future<Result<void, DataLayerError>> resendVerificationEmail() async {
    return await _authService.sendVerificationEmail();
  }
}
