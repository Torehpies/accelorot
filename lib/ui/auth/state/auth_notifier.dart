import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_application_1/data/repositories/auth_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';

part 'auth_notifier.g.dart';

@riverpod
class AuthNotifier extends _$AuthNotifier{
	@override
	FutureOr<User?> build() async {
		return FirebaseAuth.instance.currentUser;
	}

	Future<void> signInWithGoogle() async {
		state = const AsyncValue.loading();
		state = await AsyncValue.guard(() async {
			final user = await ref.
		});
	}
  
}
