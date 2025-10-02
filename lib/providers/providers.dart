
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/data/repositories/auth_repository.dart';
import 'package:flutter_application_1/services/auth_service.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// Service Provider
final authServiceProvider = Provider<AuthService>((ref) {
	return AuthService();
});

// Repository Provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
	return AuthRepository(ref.watch(authServiceProvider));
});

// Auth State Provider
final authStateProvider = StreamProvider<User?>((ref) {
	return ref.watch(authRepositoryProvider).authStateChanges;
});

