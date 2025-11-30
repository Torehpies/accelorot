import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_application_1/routes/auth_status.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

class AuthNotifier extends StateNotifier<AuthStatusState> {
  final Ref ref;
  StreamSubscription<User?>? _authStateSubscription;
  StreamSubscription<DocumentSnapshot>? _firestoreSubscription;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AuthNotifier(this.ref) : super(AuthStatusState.loading()) {
    _authStateSubscription = _auth.authStateChanges().listen(handleAuthChange);
  }

  @override
  void dispose() {
    _authStateSubscription?.cancel();
    _firestoreSubscription?.cancel();
    super.dispose();
  }

  DocumentReference _getUserDocRef(String userId) {
    return _firestore.collection('users').doc(userId);
  }

  // public checker for auth changes
  Future<void> handleAuthChange(User? user) async {
    final bool wasUnverified = state.status == AuthStatus.unverified;

    if (user == null) {
      _firestoreSubscription?.cancel();
      _firestoreSubscription = null;
      state = AuthStatusState.unauthenticated();
      return;
    }

    if (!user.emailVerified) {
      _firestoreSubscription?.cancel();
      _firestoreSubscription = null;
      state = AuthStatusState.unverified();
      return;
    }

    if (wasUnverified) {
      debugPrint(
        'User verified. Forcing state to teamSelection for immediate redirect',
      );
      state = AuthStatusState.teamSelection();
    }

    _firestoreSubscription ??= _getUserDocRef(user.uid).snapshots().listen(
      _handleFirestoreChange,
      onError: (e) => debugPrint('Firestore Listener Error: $e'),
    );
  }

  void _handleFirestoreChange(DocumentSnapshot doc) {
    if (!doc.exists || doc.data() == null) {
      state = AuthStatusState.teamSelection();
      return;
    }

    final data = doc.data()! as Map<String, dynamic>;
    final globalRole = (data['globalRole'] as String?)?.toLowerCase();
    final teamRole = (data['teamRole'] as String?)?.toLowerCase();
    final status = data['status'];

    switch (status) {
      case 'archived':
        state = AuthStatusState.archived();
        break;
      case 'pending':
        state = AuthStatusState.pendingAdminApproval();
        break;
      case 'registered':
        state = AuthStatusState.teamSelection();
        break;
      case 'active':
        if (globalRole == 'superadmin') {
          state = AuthStatusState.authenticated(role: globalRole as String);
        }
        state = AuthStatusState.authenticated(role: teamRole as String);
        break;
      default:
        state = AuthStatusState.unauthenticated();
        break;
    }
  }

  Future<void> requestTeam(String teamId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await _getUserDocRef(
        user.uid,
      ).set({'pendingTeamSelection': teamId}, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error requesting team: $e');
    }
  }

  Future<void> cancelTeam() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await _getUserDocRef(user.uid).update({
        'pendingTeamSelection': FieldValue.delete(),
        'teamId': FieldValue.delete(),
      });
    } catch (e) {
      debugPrint('Error cancelling request: $e');
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }
}

final authStateProvider = StateNotifierProvider<AuthNotifier, AuthStatusState>((
  ref,
) {
  return AuthNotifier(ref);
});
