import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/app_user_model.dart';

part 'firebase_auth_repository.g.dart';

@Riverpod(keepAlive: true)
FirebaseAuth firebaseAuth(Ref ref) {
  return FirebaseAuth.instance;
}

@Riverpod(keepAlive: true)
FirebaseAuthRepository authRepository(Ref ref) {
  final auth = ref.watch(firebaseAuthProvider);
  return FirebaseAuthRepository(auth);
}

@Riverpod(keepAlive: true)
Stream<AppUser?> authStateChange(Ref ref) {
  final auth = ref.watch(authRepositoryProvider);
  return auth.authStateChanges();
}

class FirebaseAuthRepository {
  /// Constructor ulit duh
  FirebaseAuthRepository(this._firebaseAuth);

  final FirebaseAuth _firebaseAuth;

  Stream<AppUser?> authStateChanges() {
    return _firebaseAuth.authStateChanges().map(_convertUser);
  }

  Stream<AppUser?> idTokenChanges() {
    return _firebaseAuth.idTokenChanges().map(_convertUser);
  }

  Stream<AppUser?> userChanges() {
    return _firebaseAuth.userChanges().map(_convertUser);
  }

  AppUser? get currentUser => _convertUser(_firebaseAuth.currentUser);

  /// Moved sendEmailVerification function here
  Future<void> sendEmailVerification() async {
    final user = _firebaseAuth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    } else if (user == null) {
      throw FirebaseAuthException(
        code: 'no-current-user',
        message: 'No user is currently signed in.',
      );
    }
  }

  Future<bool> isEmailVerified() async {
    final user = _firebaseAuth.currentUser;
    await user?.reload();
    return user?.emailVerified ?? false;
  }

  Future<UserCredential> signInUser({
    required String email,
    required String password,
  }) async {
    return _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  AppUser? _convertUser(User? user) =>
      user == null ? null : AppUser.fromUser(user);

 // Future<void> login({required String email, required String password}) {
 //   return _firebaseAuth.signInWithEmailAndPassword(
 //     email: email,
 //     password: password,
 //   );
 // }

  Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> updateDisplayName({required String fullName}) async {
    final user = _firebaseAuth.currentUser;
    await user?.updateDisplayName(fullName);
  }

 // Future<void> register({
 //   required String email,
 //   required String password,
 //   required String fullName,
 // }) async {
 //   await createUserWithEmailAndPassword(email: email, password: password);
 //   await updateDisplayName(fullName: fullName);
 // }

  Future<void> logout() async {
    return _firebaseAuth.signOut();
  }

  //	Future<void> signInWithGoogle() async {
  //		await _firebaseAuth.signInWithGoogle();
  //	}
}
