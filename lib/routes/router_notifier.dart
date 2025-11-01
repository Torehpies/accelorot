import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_application_1/repositories/auth_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

class RouterNotifier extends ChangeNotifier {
  final FirebaseAuth _firebaseAuth;
  late final StreamSubscription<User?> _authStateSubscription;

  User? _currentUser;
  User? get currentUser => _currentUser;

  String? _userRole;
  String? get userRole => _userRole;

  bool get isEmailVerified => currentUser?.emailVerified ?? false;

  bool get isLoggedIn => currentUser != null;

  final Ref _ref;
  RouterNotifier(this._firebaseAuth, this._ref) {
    _authStateSubscription = _firebaseAuth.authStateChanges().listen((
      user,
    ) async {
      _currentUser = user;

      if (_currentUser != null) {
        await _fetchAndSetRole(_currentUser!.uid);
      } else {
        _userRole = null;
      }
      notifyListeners();
    });

    _currentUser = _firebaseAuth.currentUser;

    if (_currentUser != null) {
      _fetchAndSetRole(_currentUser!.uid).then((_) {
        if (_currentUser?.uid == _firebaseAuth.currentUser?.uid) {
          notifyListeners();
        }
      });
    }
  }

  Future<void> _fetchAndSetRole(String uid) async {
    final authRepo = _ref.read(authRepositoryProvider);
    _userRole = await authRepo.getUserRole(uid);
  }

  Future<Map<String, dynamic>> registerAndSetState({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String role,
  }) async {
    final authRepo = _ref.read(authRepositoryProvider);

    final result = await authRepo.registerUser(
      email: email,
      password: password,
      firstName: firstName,
      lastName: lastName,
      role: role,
    );

    if (result['success'] == true) {
      _currentUser = _firebaseAuth.currentUser;
      notifyListeners();
    }
    return result;
  }

  Future<void> refreshUser() async {
    await _firebaseAuth.currentUser?.reload();
    _currentUser = _firebaseAuth.currentUser;
    notifyListeners();
  }

  @override
  void dispose() {
    _authStateSubscription.cancel();
    super.dispose();
  }
}

/// PROVIDERS
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final authListenableProvider = ChangeNotifierProvider<RouterNotifier>((ref) {
  final auth = ref.watch(firebaseAuthProvider);
  final notifier = RouterNotifier(auth, ref);

  return notifier;
});
