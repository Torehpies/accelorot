import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_application_1/repositories/team_repository.dart';
import 'package:flutter_application_1/utils/app_exceptions.dart';
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
    ref.watch(teamRepositoryProvider),
  );
}

class AuthRepository {
  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;
  final FirebaseFirestore _firestore;
  final TeamRepository _teamRepository;
  bool _isGoogleSignInInitialized = false;

  AuthRepository(
    this._auth,
    this._firestore,
    this._googleSignIn,
    this._teamRepository,
  );

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  Future<User?> registerUserWithTeam({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String role,
    required String teamId,
  }) async {
    try {
      final user = await registerUser(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        role: role,
      );

      if (user != null) {
        await _teamRepository.updatePendingTeam(user.uid, teamId);
      }

      return user;
    } on FirebaseAuthException {
      rethrow;
    } on FirebaseException {
      rethrow;
    } catch (e) {
      log(e.toString());
      throw UserRegistrationException(e.toString());
    }
  }

  Future<void> sendVerificationEmail() async {
    final user = _auth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  // Reload the user data from Firebase and return the verification status
  Future<bool> checkAndReloadEmailVerified() async {
    final user = currentUser;
    if (user != null) {
      await user.reload();
      return user.emailVerified;
    }
    return false;
  }

  Future<User?> registerUser({
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

      final user = result.user;
      if (user == null) {
        throw UserRegistrationException('Failed to create user account.');
      }

      await user.sendEmailVerification();

      await _firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'email': email,
        'firstname': firstName,
        'lastname': lastName,
        'role': role,
        'createdAt': FieldValue.serverTimestamp(),
        'isActive': true,
        'emailVerified': false,
      });

      return user;
    } on FirebaseAuthException {
      rethrow;
    } catch (e) {
      log('Unexpected registration error: $e');
      throw UserRegistrationException(
        'An unexpected error occurred during registration.',
      );
    }
  }

  Future<DocumentSnapshot> getUserData(String uid) async {
    return await _firestore.collection('users').doc(uid).get();
  }

  Future<String?> getUserRole(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      final data = doc.data();
      if (doc.exists && data != null) {
        return data['role'] as String?;
      }
      return null;
    } catch (e) {
      log('Error fetching user role for $uid: $e');
      return null;
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
