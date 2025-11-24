import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:flutter/foundation.dart';
import 'package:flutter_application_1/data/models/user.dart';
import 'package:flutter_application_1/data/repositories/user_repository.dart';
import 'package:flutter_application_1/data/services/contracts/auth_service.dart';
import 'package:flutter_application_1/data/services/contracts/data_layer_error.dart';
import 'package:flutter_application_1/data/services/contracts/result.dart';

abstract class AuthRepository {
  Stream<User?> get authStateChanges;
  User? get currentUser;
  Future<Result<void, DataLayerError>> signIn({
    required String email,
    required String password,
  });
  Future<Result<void, DataLayerError>> signOut();
}

class AuthRepositoryImpl implements AuthRepository {
  final AuthService _authService;
  final UserRepository _userRepository;

  User? _lastKnownUser;

  AuthRepositoryImpl(this._authService, this._userRepository);

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
}
