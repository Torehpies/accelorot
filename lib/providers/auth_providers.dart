import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/repositories/auth_repository.dart';
import 'package:flutter_application_1/repositories/team_repository.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_providers.g.dart';

/// Riverpod Providers

/// Auth state changes stream provider
@Riverpod(keepAlive: true)
Stream<User?> authStateChanges(Ref ref) {
	return ref.watch(authRepositoryProvider).authStateChanges;
}

/// Firebase auth provider
@Riverpod(keepAlive: true)
FirebaseAuth firebaseAuth(Ref ref) => FirebaseAuth.instance;

/// Firebase Firestore provider
@Riverpod(keepAlive: true)
FirebaseFirestore firebaseFirestore(Ref ref) => FirebaseFirestore.instance;

/// Auth Repository provider
@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) {
  return AuthRepository(
    ref.watch(firebaseAuthProvider),
    ref.watch(firebaseFirestoreProvider),
    GoogleSignIn.instance,
    ref.watch(teamRepositoryProvider),
  );
}

/// Team Repository provider
@Riverpod(keepAlive: true)
TeamRepository teamRepository(Ref ref) {
  return TeamRepository(ref.watch(firebaseFirestoreProvider));
}

/// Team list provider
@riverpod
Future<List<Team>> teamList(Ref ref) {
  final teamRepo = ref.watch(teamRepositoryProvider);
  return teamRepo.fetchAllTeams();
}
