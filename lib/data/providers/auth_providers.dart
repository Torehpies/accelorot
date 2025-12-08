import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/data/models/app_user.dart';
import 'package:flutter_application_1/data/models/user_doc.dart';
import 'package:flutter_application_1/data/providers/app_user_providers.dart';
import 'package:flutter_application_1/data/providers/core_providers.dart';
import 'package:flutter_application_1/data/providers/pending_member_providers.dart';
import 'package:flutter_application_1/data/repositories/auth_repository/auth_repository.dart';
import 'package:flutter_application_1/data/repositories/auth_repository/auth_repository_remote.dart';
import 'package:flutter_application_1/data/services/contracts/auth_service.dart';
import 'package:flutter_application_1/data/services/firebase/firebase_auth_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_providers.g.dart';

@Riverpod(keepAlive: true)
AuthService authService(Ref ref) {
  final firebaseAuth = ref.read(firebaseAuthProvider);
  return FirebaseAuthService(firebaseAuth);
}

@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) {
  final authService = ref.read(authServiceProvider);
  final userRepository = ref.read(appUserRepositoryProvider);
  final pendingMemberService = ref.read(pendingMemberServiceProvider);
  final firebaseAuth = ref.read(firebaseAuthProvider);
  final userService = ref.read(appUserServiceProvider);

  return AuthRepositoryRemote(
    authService,
    userRepository,
    pendingMemberService,
    firebaseAuth,
    userService,
  );
}

@Riverpod(keepAlive: true)
Stream<User?> authUser(Ref ref) {
  final firebase = ref.watch(firebaseAuthProvider);
  return firebase.authStateChanges();
}

//@Riverpod(keepAlive: true)
@riverpod
Stream<AppUser?> appUser(Ref ref) {
  final authUser = ref.watch(authUserProvider);

  return authUser.when(
    error: (_, _) => const Stream.empty(),
    loading: () => const Stream.empty(),
    data: (firebaseUser) {
      if (firebaseUser == null) return Stream.value(null);
      final service = ref.watch(appUserServiceProvider);
      return service.getAppUser(firebaseUser.uid);
    },
  );
}

@Riverpod(keepAlive: true)
Stream<UserDoc?> userDoc(Ref ref) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  final user = ref.watch(authUserProvider).value;
  if (user == null) return const Stream.empty();

  return firestore
      .collection('users')
      .doc(user.uid)
      .snapshots()
      .map((doc) => doc.exists ? UserDoc.fromJson(doc.data()!) : null);
}
