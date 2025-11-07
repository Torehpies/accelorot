import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_application_1/repositories/auth_repository.dart';
import 'package:flutter_application_1/routes/auth_status.dart';
import 'package:flutter_riverpod/legacy.dart';

class AuthNotifier extends StateNotifier<AuthStatus> {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  late final StreamSubscription<User?> _authStateSubscription;
  StreamSubscription<DocumentSnapshot>? _userDocSubscription;

  AuthNotifier(this._auth, this._firestore) : super(Unauthenticated()) {
    _authStateSubscription = _auth.authStateChanges().listen(_handleAuthChange);
  }

  DocumentReference _getUserDocRef(String userId) {
    return _firestore.collection('users').doc(userId);
  }

  Future<void> _handleAuthChange(User? user) async {
    await _userDocSubscription?.cancel();
    _userDocSubscription = null;

    if (user == null) {
      state = Unauthenticated();
      return;
    }

    if (!user.emailVerified) {
      state = Unverified();
      return;
    }

    _userDocSubscription = _getUserDocRef(user.uid).snapshots().listen(
      _handleFirestoreChange,
      onError: (e) {
        if (kDebugMode) print('Firestore status stream error: $e');
        state = TeamSelection();
      },
    );
  }

  void _handleFirestoreChange(DocumentSnapshot doc) {
    if (!doc.exists || doc.data() == null) {
      state = TeamSelection();
      return;
    }

    final data = doc.data() as Map<String, dynamic>;
    final String? pendingTeamId = data['pendingTeamSelection'];
    final String? teamId = data['teamId'];
    final String? roleString = data['role'];

    if (pendingTeamId != null && pendingTeamId.isNotEmpty) {
      state = PendingAdminApproval(pendingTeamId);
    } else if (teamId != null && teamId.isNotEmpty) {
      final role = _parseRole(roleString);
      state = Authenticated(role);
    } else {
      state = TeamSelection();
    }
  }

  UserRole _parseRole(String? roleString) {
    final normalizedRole = roleString?.toLowerCase();
    if (normalizedRole == 'admin') return UserRole.Admin;
    if (normalizedRole == 'superadmin') return UserRole.SuperAdmin;
    return UserRole.Operator;
  }

  Future<void> sendVerificationEmail() async {
    await _auth.currentUser?.sendEmailVerification();
  }

  Future<void> checkEmailVerification() async {
    await _auth.currentUser?.reload();
    await _handleAuthChange(_auth.currentUser);
  }

  @override
  void dispose() {
    _authStateSubscription.cancel();
    _userDocSubscription?.cancel();
    super.dispose();
  }
}

final authStateProvider = StateNotifierProvider<AuthNotifier, AuthStatus>((
  ref,
) {
  final auth = ref.watch(firebaseAuthProvider);
  final firestore = ref.watch(firebaseFirestoreProvider);

  return AuthNotifier(auth, firestore);
});
