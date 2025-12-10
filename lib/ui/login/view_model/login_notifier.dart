import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/providers/auth_providers.dart';

import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'login_notifier.g.dart';

@riverpod
class LoginNotifier extends _$LoginNotifier {
  @override
  FutureOr<void> build() {
    return null;
  }

  Future<void> signInWithEmail(String email, String password) async {
    state = const AsyncLoading();
    final authRepo = ref.read(authRepositoryProvider);

    try {
      await authRepo.signInWithEmail(email, password);
      state = AsyncLoading();
    } on FirebaseAuthException catch (e, st) {
      state = AsyncError(e, st);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> signInWithGoogle() async {
    final authRepo = ref.read(authRepositoryProvider);
    state = AsyncLoading();

    try {
      final result = await authRepo.signInWithGoogle();
			//TODO GOOGLE SIGN IN

      // if (result is GoogleLoginSuccess) {
      //   /// stop loading on google sign-in success
      //   state = state.copyWith(isLoading: false, errorMessage: null);
      // } else if (result is GoogleLoginFailure) {
      //   /// stop loading on google sign-in failure
      //   state = state.copyWith(isLoading: false, errorMessage: result.message);
      // }
    } on Exception catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}
