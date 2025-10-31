import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

class RouterNotifier extends ChangeNotifier {
  final FirebaseAuth _firebaseAuth;
  late final StreamSubscription<User?> _authStateSubscription;

  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;

  RouterNotifier(this._firebaseAuth) {
    _authStateSubscription = _firebaseAuth.authStateChanges().listen((user) {
      final newAuthState = user != null;
      if (_isLoggedIn != newAuthState) {
        _isLoggedIn = newAuthState;
        notifyListeners();
      }
    });

		_isLoggedIn = _firebaseAuth.currentUser != null;
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
