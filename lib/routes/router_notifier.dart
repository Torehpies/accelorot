import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_application_1/repositories/auth_repository.dart';
import 'package:flutter_application_1/repositories/team_repository.dart';
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

  bool? _isPending = false;
  bool? get isPending => _isPending;

  bool? _isInTeam = false;
  bool? get isInTeam => _isInTeam;

  final Ref _ref;

  final Completer<void> _initializationCompleter = Completer<void>();
  Future<void> get isInitialized => _initializationCompleter.future;

  RouterNotifier(this._firebaseAuth, this._ref) {
    _authStateSubscription = _firebaseAuth.authStateChanges().listen((
      user,
    ) async {
      _currentUser = user;

      if (_currentUser != null) {
        await _fetchAndSetRole(_currentUser!.uid);
        //await _fetchAndSetIsPending(_currentUser!.uid);
        //await _fetchAndSetIsInTeam(_currentUser!.uid);
        await _fetchAndSetIsPendingAndIsInTeam(_currentUser!.uid);
      } else {
        _userRole = null;
      }
      notifyListeners();

      if (!_initializationCompleter.isCompleted) {
        _initializationCompleter.complete();
      }
    });

    _currentUser = _firebaseAuth.currentUser;

    if (_currentUser != null) {
      _fetchAndSetRole(_currentUser!.uid).then((_) async {
        if (_currentUser?.uid == _firebaseAuth.currentUser?.uid) {
          //await _fetchAndSetIsInTeam(_currentUser!.uid);
          //await _fetchAndSetIsPending(_currentUser!.uid);
          await _fetchAndSetIsPendingAndIsInTeam(_currentUser!.uid);
          notifyListeners();
        }

        if (!_initializationCompleter.isCompleted) {
          _initializationCompleter.complete();
        }
      });
    }
  }

  Future<void> _fetchAndSetRole(String uid) async {
    final authRepo = _ref.read(authRepositoryProvider);
    _userRole = await authRepo.getUserRole(uid);
  }

  Future<void> _fetchAndSetIsPending(String uid) async {
    final teamRepo = _ref.read(teamRepositoryProvider);
    final result = await teamRepo.getPendingTeam(uid);
    _isPending = result != null ? true : false;
  }

  Future<void> _fetchAndSetIsInTeam(String uid) async {
    final teamRepo = _ref.read(teamRepositoryProvider);
    final result = await teamRepo.getTeamId(uid);
    _isInTeam = result != null ? true : false;
  }

  Future<void> _fetchAndSetIsPendingAndIsInTeam(String uid) async {
    final teamRepo = _ref.read(teamRepositoryProvider);
    final isPendingResult = await teamRepo.getPendingTeam(uid);
    final isInTeamResult = await teamRepo.getTeamId(uid);
    _isPending = isPendingResult != null ? true : false;
    _isInTeam = isInTeamResult != null ? true : false;
  }

  Future<void> registerAndSetState({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String role,
    required String teamId,
  }) async {
    final authRepo = _ref.read(authRepositoryProvider);

    try {
      await authRepo.registerUserWithTeam(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        role: role,
        teamId: teamId,
      );
      _currentUser = _firebaseAuth.currentUser;
      notifyListeners();
    } on FirebaseAuthException {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> refreshUser() async {
    await _firebaseAuth.currentUser?.reload();
    _currentUser = _firebaseAuth.currentUser;
    notifyListeners();
  }

  Future<void> refreshIsInTeam() async {
    await _fetchAndSetIsInTeam(_currentUser!.uid);
    notifyListeners();
  }

  Future<void> refreshIsPending() async {
    await _fetchAndSetIsPending(_currentUser!.uid);
    notifyListeners();
  }

  @override
  void dispose() {
    _authStateSubscription.cancel();
    super.dispose();
  }
}

/// PROVIDERS
final authListenableProvider = ChangeNotifierProvider<RouterNotifier>((ref) {
  final auth = ref.watch(firebaseAuthProvider);
  final notifier = RouterNotifier(auth, ref);

  return notifier;
});
