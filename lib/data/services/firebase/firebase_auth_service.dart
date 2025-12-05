import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_application_1/data/services/contracts/auth_service.dart';
import 'package:flutter_application_1/data/services/contracts/data_layer_error.dart';
import 'package:flutter_application_1/data/services/contracts/result.dart';
import 'package:flutter_application_1/data/utils/map_firebase_exception.dart';

class FirebaseAuthService implements AuthService {
  final FirebaseAuth _firebaseAuth;

  FirebaseAuthService(this._firebaseAuth);

  @override
  String? get currentUserUid => _firebaseAuth.currentUser?.uid;

  @override
  Stream<String?> get onAuthStateChanged {
    return _firebaseAuth.authStateChanges().map((user) => user?.uid);
  }

  @override
  Future<String> signInWithEmail(String email, String password) async {
    final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    return userCredential.user!.uid;
  }

  @override
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  @override
  Future<String> signUp(String email, String password) async {
    try {
      UserCredential result = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);
      final user = result.user;

      await user?.sendEmailVerification();

      return result.user!.uid;
    } on FirebaseAuthException {
      rethrow;
    }
  }

  @override
  Future<Result<void, DataLayerError>> sendVerificationEmail() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null || user.emailVerified) {
        return Result.failure(DataLayerError.emailVerificationError());
      }
      await user.sendEmailVerification();
      return Result.success(null);
    } on FirebaseException catch (e) {
      return Result.failure(mapFirebaseException(e));
    } catch (e) {
      debugPrint('Unexpected error on creating user profile: $e');
      return Result.failure(DataLayerError.unknownError(e));
    }
  }

  @override
  Future<Result<bool, DataLayerError>> checkEmailVerified() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) return Result.success(false);
      await user.reload();
			debugPrint("Email verified.");
      return Result.success(_firebaseAuth.currentUser?.emailVerified ?? false);
    } on FirebaseException catch (e) {
      return Result.failure(mapFirebaseException(e));
    } catch (e) {
      return Result.failure(DataLayerError.unknownError(e));
    }
  }
}
