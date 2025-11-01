import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

class RouterNotifier extends ChangeNotifier {
  final FirebaseAuth _firebaseAuth;
  late final StreamSubscription<User?> _authStateSubscription;

  User? _currentUser;
  User? get currentUser => _currentUser;

  bool get isEmailVerified => currentUser?.emailVerified ?? false;

  bool get isLoggedIn => currentUser != null;

  RouterNotifier(this._firebaseAuth) {
    _authStateSubscription = _firebaseAuth.authStateChanges().listen((user) {
      if (_currentUser != null) {
        _currentUser = user;
        notifyListeners();
      }
    });

		_currentUser = _firebaseAuth.currentUser;
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
  final notifier = RouterNotifier(auth);

  return notifier;
});
