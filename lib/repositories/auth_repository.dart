import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_application_1/utils/google_auth_result.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_repository.g.dart';

@Riverpod(keepAlive: true)
FirebaseAuth firebaseAuth(Ref ref) => FirebaseAuth.instance;

@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) {
  return AuthRepository(ref.watch(firebaseAuthProvider), GoogleSignIn.instance);
}

class AuthRepository {
  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;
  bool _isGoogleSignInInitialized = false;

  AuthRepository(this._auth, this._googleSignIn);

  Stream<User?> get authStateChanges => _auth.authStateChanges();
	User? get currentUser => _auth.currentUser;

  Future<User?> signInWithEmail(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } on FirebaseAuthException {
      rethrow;
    }
  }

  Future<GoogleAuthResult> signInWithGoogle() async {
    if (kIsWeb) {
      try {
        final GoogleAuthProvider googleProvider = GoogleAuthProvider();
        final UserCredential credential = await _auth.signInWithPopup(
          googleProvider,
        );

        if (credential.user?.uid != null) {
          return GoogleLoginSuccess(credential.user!.uid);
        }
        return GoogleLoginFailure('Google sign-in but user id is empty.');
      } on FirebaseAuthException catch (e) {
        log('Firebase Web Sign In Error: ${e.code} - ${e.message}');
        return GoogleLoginFailure('Google sign-in failed: $e');
      } catch (error) {
        log('Unexpected Web Sign-In Error: $error');
        return GoogleLoginFailure('An unexpected error occured.');
      }
    } else {
      await _ensureGoogleSignInInitialized();

      try {
        final GoogleSignInAccount googleUser = await _googleSignIn
            .authenticate();

        final GoogleSignInAuthentication googleAuth = googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          idToken: googleAuth.idToken,
        );
        await _auth.signInWithCredential(credential);

        return GoogleLoginSuccess(_auth.currentUser!.uid);
      } on GoogleSignInException catch (e) {
        log(
          'Google Sign In error: code: ${e.code.name} description:${e.description}',
        );
        return GoogleLoginFailure('Google sign-in error occured.');
      } catch (error) {
        log('Unexpected Google Sign-In error: $error');
        return GoogleLoginFailure('An unexpected error occured.');
      }
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  Future<void> _ensureGoogleSignInInitialized() async {
    if (!_isGoogleSignInInitialized) {
      await _initializeGoogleSignIn();
    }
  }

  Future<void> _initializeGoogleSignIn() async {
    try {
      await _googleSignIn.initialize();
      _isGoogleSignInInitialized = true;
    } catch (e) {
      log('Failed to initialize Google Sign-In: $e');
    }
  }
}
