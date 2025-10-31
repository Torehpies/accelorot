import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/repositories/auth_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_providers.g.dart';

@Riverpod(keepAlive: true)
Stream<User?> authStateChanges(Ref ref) {
	return ref.watch(authRepositoryProvider).authStateChanges;
}
