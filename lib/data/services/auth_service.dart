import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/data/models/app_user_model.dart';
import 'package:flutter_application_1/data/repositories/firebase_auth_repository.dart';
import 'package:flutter_application_1/data/repositories/firestore_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_service.g.dart';

class EmailNotVerifiedException implements Exception {
  final String message = 'Email not verified. Please verify your email.';
  final String uid;
  EmailNotVerifiedException(this.uid);
  @override
  String toString() => message;
}

class UserDataNotFoundException implements Exception {
  final String message = 'User data not found in Firestore.';
  @override
  String toString() => message;
}

class EmailAlreadyVerifiedException implements Exception {
  final String message = 'Email is already verified.';
  @override
  String toString() => message;
}

@Riverpod(keepAlive: true)
AuthService authService(Ref ref) {
  final authRepo = ref.watch(authRepositoryProvider);
  final firestoreRepo = ref.watch(firestoreRepositoryProvider);
  return AuthService(authRepo, firestoreRepo);
}

class AuthService {
  final FirebaseAuthRepository _authRepo;
  final FirestoreRepository _firestoreRepo;

  AuthService(this._authRepo, this._firestoreRepo);

  Future<void> sendEmailVerify() async {
    final user = _authRepo.currentUser;
    if (user != null && user.emailVerified) {
      throw EmailAlreadyVerifiedException();
    }
    await _authRepo.sendEmailVerification();
  }

  Future<bool> isEmailVerified() async {
    return _authRepo.isEmailVerified();
  }

  Future<void> updateEmailVerificationStatus(
    String uid,
    bool isVerified,
  ) async {
    await _firestoreRepo.updateEmailVerificationStatus(uid, isVerified);
  }

  Future<Map<String, dynamic>> signInUser({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _authRepo.signInUser(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        throw Exception('Sign in failed, user is null.');
      }

      if (!user.emailVerified) {
        await _authRepo.logout();
        throw EmailNotVerifiedException(user.uid);
      }

      final DocumentSnapshot userDoc = await _firestoreRepo.getUserData(
        user.uid,
      );

      if (userDoc.exists) {
        return {
          'success': true,
          'message': 'Sign in successful',
          'uid': user.uid,
          'userData': userDoc.data(),
        };
      } else {
        // Optional: Sign out if Firestore data is missing
        await _authRepo.logout();
        return {
          'success': false,
          'message': 'User data not found in Firestore',
        };
      }
    } on FirebaseAuthException catch (e) {
      // Replicates your colleague's detailed error mapping
      final message = _mapAuthException(e);
      return {'success': false, 'message': message};
    } catch (e) {
      return {
        'success': false,
        'message': 'An unexpected error occurred: ${e.toString()}',
      };
    }
  }

  Future<Map<String, dynamic>> registerUser({
    required String email,
    required String password,
    required String fullName,
    required String role,
  }) async {
    try {
      final credential = await _authRepo.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        throw Exception('User creation failed');
      }

      await _firestoreRepo.saveNewUser(
        uid: user.uid,
        email: email,
        fullName: fullName,
        role: role,
      );

      await user.sendEmailVerification();

      //await _authRepo.updateDisplayName(fullName: fullName);

      return {
        'success': true,
        'message': 'User registered successfully',
        'uid': user.uid,
        'needsVerification': true,
      };
    } on FirebaseAuthException catch (e) {
      final message = _mapAuthException(e);
      return {'success': false, 'message': message};
    } catch (e) {
      return {
        'success': false,
        'message': 'An unexpeceted error occured: ${e.toString()}',
      };
    }
  }

  Future<void> signOut() async {
    return _authRepo.logout();
  }

  AppUser? getCurrentUser() {
    return _authRepo.currentUser;
  }

  String _mapAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found for that email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'too-many-requests':
        return 'Too many failed login attempts. Please try again later.';
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'email-already-in-use':
        return 'The account already exists for that email.';
      default:
        return e.message ?? 'An error occurred during authentication.';
    }
  }
}
