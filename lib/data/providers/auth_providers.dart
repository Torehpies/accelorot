import 'package:flutter_application_1/data/repositories/firebase_auth_repository.dart';
import 'package:flutter_application_1/data/services/firebase_auth_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final firebaseAuthServiceProvider = Provider<FirebaseAuthService>((ref) {
	return FirebaseAuthService();
});

final firebaseAuthRepositoryProvider = Provider<FirebaseAuthRepository>((ref) {
	final service = ref.watch(firebaseAuthServiceProvider);
	return FirebaseAuthRepository(service);
});

final authStateProvider = StreamProvider((ref) {
	final repo = ref.watch(firebaseAuthRepositoryProvider);
	return repo.authStateChanges;
});
