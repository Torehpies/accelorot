//import 'dart:async';
//
//import 'package:firebase_auth/firebase_auth.dart';
//import 'package:flutter/foundation.dart';
//import 'package:flutter_application_1/repositories/auth_repository.dart';
//import 'package:flutter_application_1/repositories/team_repository.dart';
//import 'package:flutter_application_1/routes/auth_status.dart';
//import 'package:flutter_application_1/routes/router_state.dart';
//import 'package:flutter_riverpod/flutter_riverpod.dart';
//
//class RouterNotifier extends Notifier<RouterState> implements Listenable {
//  final _listener = ValueNotifier<int>(0);
//  late final StreamSubscription<User?> _authStateSubscription;
//
//  RouterNotifier({required Ref ref}) {
//    final firebaseAuth = ref.read(firebaseAuthProvider);
//
//    _authStateSubscription = firebaseAuth.authStateChanges().listen((
//      user,
//    ) async {
//      await _updateStateBasedOnUser(user, firebaseAuth);
//    });
//  }
//
//  @override
//  void addListener(VoidCallback listener) => _listener.addListener(listener);
//
//  @override
//  void removeListener(VoidCallback listener) =>
//      _listener.removeListener(listener);
//
//  void _notifyGoRouter() => _listener.value = _listener.value + 1;
//
//  @override
//  RouterState build() {
//    final firebaseAuth = ref.watch(firebaseAuthProvider);
//
//    ref.onDispose(() {
//      _authStateSubscription.cancel();
//      _listener.dispose();
//    });
//
//    _updateStateBasedOnUser(firebaseAuth.currentUser, firebaseAuth);
//    return RouterState(status: AuthStatus.loading, isEmailVerified: false);
//  }
//
//  Future<void> _updateStateBasedOnUser(
//    User? user,
//    FirebaseAuth firebaseAuth,
//  ) async {
//    if (user == null) {
//      state = RouterState(
//        status: AuthStatus.unauthenticated,
//        isEmailVerified: false,
//      );
//    } else {
//      await user.reload();
//      final updatedUser = firebaseAuth.currentUser;
//      final isVerified = updatedUser?.emailVerified ?? false;
//
//      if (!isVerified) {
//        state = RouterState(
//          status: AuthStatus.needsEmailVerification,
//          uid: user.uid,
//          isEmailVerified: false,
//        );
//      } else {
//        final authRepo = ref.read(authRepositoryProvider);
//        final teamRepo = ref.read(teamRepositoryProvider);
//
//        final results = await Future.wait([
//          authRepo.getUserRole(user.uid),
//          teamRepo.getPendingTeam(user.uid),
//          teamRepo.getTeamId(user.uid),
//        ]);
//
//        final userRole = results[0];
//        final isPending = results[1] != null;
//        final isInTeam = results[2] != null;
//
//        if (isPending) {
//          state = RouterState(
//            status: AuthStatus.waitingForApproval,
//            uid: user.uid,
//            isEmailVerified: true,
//          );
//        } else if (!isInTeam) {
//          state = RouterState(
//            status: AuthStatus.needsTeamSelection,
//            uid: user.uid,
//            isEmailVerified: true,
//          );
//        } else if (userRole == 'Admin') {
//          state = RouterState(
//            status: AuthStatus.authenticatedAdmin,
//            uid: user.uid,
//            isEmailVerified: true,
//          );
//        } else if (userRole == 'SuperAdmin') {
//          state = RouterState(
//            status: AuthStatus.authenticatedSuperAdmin,
//            uid: user.uid,
//            isEmailVerified: true,
//          );
//        } else {
//          state = RouterState(
//            status: AuthStatus.authenticatedOperator,
//            uid: user.uid,
//            isEmailVerified: true,
//          );
//        }
//      }
//    }
//    _notifyGoRouter();
//  }
//
//  Future<void> refreshState() async {
//    final firebaseAuth = ref.read(firebaseAuthProvider);
//    await _updateStateBasedOnUser(firebaseAuth.currentUser, firebaseAuth);
//  }
//}
//
///// PROVIDERS
//final authListenableProvider = NotifierProvider<RouterNotifier, RouterState>(
//  RouterNotifier(ref: ref),
//);

// User? _currentUser;
// User? get currentUser => _currentUser;

// String? _userRole;
// String? get userRole => _userRole;

// bool get isEmailVerified => currentUser?.emailVerified ?? false;

// bool get isLoggedIn => currentUser != null;

// bool? _isPending = false;
// bool? get isPending => _isPending;

// bool? _isInTeam = false;
// bool? get isInTeam => _isInTeam;

// bool? _isLoading = false;
// bool? get isLoading => _isLoading;

// final Ref _ref;

// final Completer<void> _initializationCompleter = Completer<void>();
// Future<void> get isInitialized => _initializationCompleter.future;

// RouterNotifier(this._firebaseAuth, this._ref) {
//   _authStateSubscription = _firebaseAuth.authStateChanges().listen((
//     user,
//   ) async {
//     _currentUser = user;

//     if (_currentUser != null) {
//       await _fetchAndSetRole(_currentUser!.uid);
//       //await _fetchAndSetIsPending(_currentUser!.uid);
//       //await _fetchAndSetIsInTeam(_currentUser!.uid);
//       await _fetchAndSetIsPendingAndIsInTeam(_currentUser!.uid);
//     } else {
//       _userRole = null;
//     }
//     notifyListeners();

//     if (!_initializationCompleter.isCompleted) {
//       _initializationCompleter.complete();
//     }
//   });

//   _currentUser = _firebaseAuth.currentUser;

//   if (_currentUser != null) {
//     _fetchAndSetRole(_currentUser!.uid).then((_) async {
//       if (_currentUser?.uid == _firebaseAuth.currentUser?.uid) {
//         //await _fetchAndSetIsInTeam(_currentUser!.uid);
//         //await _fetchAndSetIsPending(_currentUser!.uid);
//         await _fetchAndSetIsPendingAndIsInTeam(_currentUser!.uid);
//         notifyListeners();
//       }

//       if (!_initializationCompleter.isCompleted) {
//         _initializationCompleter.complete();
//       }
//     });
//   }
// }

//  Future<void> _fetchAndSetRole(String uid) async {
//    final authRepo = _ref.read(authRepositoryProvider);
//    _userRole = await authRepo.getUserRole(uid);
//  }
//
//  Future<void> _fetchAndSetIsPending(String uid) async {
//    final teamRepo = _ref.read(teamRepositoryProvider);
//    final result = await teamRepo.getPendingTeam(uid);
//    _isPending = result != null ? true : false;
//  }
//
//  Future<void> _fetchAndSetIsInTeam(String uid) async {
//    final teamRepo = _ref.read(teamRepositoryProvider);
//    final result = await teamRepo.getTeamId(uid);
//    _isInTeam = result != null ? true : false;
//  }
//
//  Future<void> _fetchAndSetIsPendingAndIsInTeam(String uid) async {
//    final teamRepo = _ref.read(teamRepositoryProvider);
//    final isPendingResult = await teamRepo.getPendingTeam(uid);
//    final isInTeamResult = await teamRepo.getTeamId(uid);
//    _isPending = isPendingResult != null ? true : false;
//    _isInTeam = isInTeamResult != null ? true : false;
//  }
//
//  Future<void> registerAndSetState({
//    required String email,
//    required String password,
//    required String firstName,
//    required String lastName,
//    required String role,
//    required String teamId,
//  }) async {
//    final authRepo = _ref.read(authRepositoryProvider);
//
//    try {
//      await authRepo.registerUserWithTeam(
//        email: email,
//        password: password,
//        firstName: firstName,
//        lastName: lastName,
//        role: role,
//        teamId: teamId,
//      );
//      _currentUser = _firebaseAuth.currentUser;
//      notifyListeners();
//    } on FirebaseAuthException {
//      rethrow;
//    } catch (e) {
//      rethrow;
//    }
//  }
//
//  Future<void> refreshUser() async {
//    await _firebaseAuth.currentUser?.reload();
//    _currentUser = _firebaseAuth.currentUser;
//    notifyListeners();
//  }
//
//  Future<void> refreshIsInTeam() async {
//    await _fetchAndSetIsInTeam(_currentUser!.uid);
//    notifyListeners();
//  }
//
//  Future<void> refreshIsPending() async {
//    await _fetchAndSetIsPending(_currentUser!.uid);
//    notifyListeners();
//  }
//

//final authListenableProvider = ChangeNotifierProvider<RouterNotifier>((ref) {
//  final auth = ref.watch(firebaseAuthProvider);
//  final notifier = RouterNotifier(auth, ref);
//
//  return notifier;
//});
