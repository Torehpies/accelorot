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

  AppUser? _convertUser(User? user) =>
      user == null ? null : AppUser.fromUser(user);

  Future<void> login({required String email, required String password}) {
    return _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> updateDisplayName({required String fullName}) async {
    final user = _firebaseAuth.currentUser;
    await user?.updateDisplayName(fullName);
  }

  Future<void> register({
    required String email,
    required String password,
    required String fullName,
  }) async {
    await createUserWithEmailAndPassword(email: email, password: password);
    await updateDisplayName(fullName: fullName);
  }

  Future<void> logout() async {
    return _firebaseAuth.signOut();
  }

  //	Future<void> register(String email, String password, String fullName) async {
  //		await _firebaseAuth.registerWithEmail(email, password, fullName);
  //	}
  //
  //	Future<User?> login(String email, String password) async {
  //		final credential = await _firebaseAuth.signInWithEmail(email, password);
  //		return credential?.user;
  //	}
  //
  //
  //	Future<void> signInWithGoogle() async {
  //		await _firebaseAuth.signInWithGoogle();
  //	}
}
