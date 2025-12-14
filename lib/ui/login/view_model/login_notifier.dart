import 'package:flutter_application_1/data/providers/auth_providers.dart';
import 'package:flutter_application_1/data/services/contracts/result.dart';
// import 'package:flutter_application_1/providers/auth_providers.dart';

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
    final result = await authRepo.signIn(email: email, password: password);
    result.when(
      success: (success) {
        state = AsyncData(success);
      },
      failure: (error) {
        state = AsyncError(error.userFriendlyMessage, StackTrace.current);
      },
    );
  }

  Future<void> signInWithGoogle() async {
    final authRepo = ref.read(authRepositoryProvider);
    state = AsyncLoading();

    final result = await authRepo.signInWithGoogle();
    result.when(
      success: (_) => AsyncData(null),
      failure: (error) =>
          AsyncError(error.userFriendlyMessage, StackTrace.current),
    );
  }
}
