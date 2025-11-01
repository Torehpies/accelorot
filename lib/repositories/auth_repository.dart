import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_application_1/utils/google_auth_result.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_repository.g.dart';

@Riverpod(keepAlive: true)
FirebaseAuth firebaseAuth(Ref ref) => FirebaseAuth.instance;

@Riverpod(keepAlive: true)
FirebaseFirestore firebaseFirestore(Ref ref) => FirebaseFirestore.instance;

@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) {
  return AuthRepository(
    ref.watch(firebaseAuthProvider),
    ref.watch(firebaseFirestoreProvider),
    GoogleSignIn.instance,
  );
}

class AuthRepository {
  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;
  final FirebaseFirestore _firestore;
  bool _isGoogleSignInInitialized = false;

  AuthRepository(this._auth, this._firestore, this._googleSignIn);

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  Future<Map<String, dynamic>> registerUser({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String role,
  }) async {
    try {
      // Create user with Firebase Auth
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = result.user;
      if (user != null) {
        await user.sendEmailVerification();
        // Save additional user data to Firestore
        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'email': email,
          // Store names separately (no concatenation)
          // Note: keys are intentionally cased to match requested schema
          'firstname': firstName,
          'lastname': lastName,
          'role': role,
          'createdAt': FieldValue.serverTimestamp(),
          'isActive': true,
          'emailVerified': false,
        });

        return {
          'success': true,
          'message': 'User registered successfully',
          'uid': user.uid,
          'needsVerification': true,
        };
      } else {
        return {'success': false, 'message': 'Failed to create user account'};
      }
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'weak-password':
          message = 'The password provided is too weak.';
          break;
        case 'email-already-in-use':
          message = 'The account already exists for that email.';
          break;
        case 'invalid-email':
          message = 'The email address is not valid.';
          break;
        default:
          message = e.message ?? 'An error occurred during registration.';
      }
      return {'success': false, 'message': message};
    } catch (e) {
      return {
        'success': false,
        'message': 'An unexpected error occurred: ${e.toString()}',
      };
    }
  }

  Future<User?> signInWithEmail(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      //await ref.read(authListenableProvider).refreshUser();
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
