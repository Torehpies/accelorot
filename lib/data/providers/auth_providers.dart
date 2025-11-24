import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:flutter_application_1/data/models/user.dart';
import 'package:flutter_application_1/data/providers/user_providers.dart';
import 'package:flutter_application_1/data/repositories/auth_repository.dart';
import 'package:flutter_application_1/data/services/contracts/auth_service.dart';
import 'package:flutter_application_1/data/services/firebase/firebase_auth_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_providers.g.dart';

@Riverpod(keepAlive: true)
FirebaseAuth firebaseAuth(Ref ref) => FirebaseAuth.instance;

@Riverpod(keepAlive: true)
AuthService authService(Ref ref) {
	final firebaseAuth = ref.watch(firebaseAuthProvider);
	return FirebaseAuthService(firebaseAuth);
}

@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) {
	final authService = ref.watch(authServiceProvider);
	final userRepository = ref.watch(userRepositoryProvider);

	return AuthRepositoryImpl(authService, userRepository);
}

@Riverpod(keepAlive: true)
Stream<User?> authState(Ref ref) {
	final repository = ref.watch(authRepositoryProvider);
	return repository.authStateChanges;
}
