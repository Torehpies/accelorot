import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_application_1/repositories/auth_repository.dart';
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
    _authStateSubscription = _auth.authStateChanges().listen(_handleAuthChange);
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

  Future<void> _handleAuthChange(User? user) async {
    if (user == null) {
      _firestoreSubscription?.cancel();
      state = AuthStatusState.unauthenticated();
      return;
    }

    if (!user.emailVerified) {
      _firestoreSubscription?.cancel();
      state = AuthStatusState.unverified();
      return;
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
    final userRole = data['role'] as String?;

    if (userRole == null) {
      state = AuthStatusState.teamSelection();
      return;
    }

    if (data.containsKey('pendingTeamSelection')) {
      state = AuthStatusState.pendingAdminApproval();
    } else if (data.containsKey('teamId')) {
      state = AuthStatusState.authenticated(role: userRole);
    } else {
      state = AuthStatusState.teamSelection();
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
