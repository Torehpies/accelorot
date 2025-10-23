import 'package:flutter_application_1/data/repositories/firebase_auth_repository.dart';
import 'package:flutter_application_1/data/services/auth_service.dart';
import 'package:flutter_application_1/utils/auth_utils.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_view_model.g.dart';

@riverpod
class AuthViewModel extends _$AuthViewModel {
  @override
  FutureOr<void> build() => null;

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();

    final authService = ref.watch(authServiceProvider);
    try {
      final result = await authService.signInUser(
        email: email,
        password: password,
      );

      if (result['success'] == true) {
        state = const AsyncValue.data(null);
      } else {
        final message = result['message'] as String;

        state = AsyncValue.error(message, StackTrace.current);
      }
    } catch (e, st) {
      final message = getFriendlyErrorMessage(e);
      state = AsyncValue.error(message, st);
    }
  }

  /// Default role 'user'
  Future<void> register(
    String email,
    String password,
    String fullName, {
    String role = 'user',
  }) async {
    state = const AsyncValue.loading();

    final authService = ref.watch(authServiceProvider);
    try {
      final result = await authService.registerUser(
        email: email,
        password: password,
        fullName: fullName,
        role: role,
      );

      if (!ref.mounted) return;

      if (result['success'] == true) {
        state = const AsyncValue.data(null);
      } else {
        final message = result['message'] as String;
        state = AsyncValue.error(message, StackTrace.current);
      }
    } catch (e, st) {
      if (!ref.mounted) return;
      final message = getFriendlyErrorMessage(e);
      state = AsyncValue.error(message, st);
    }
  }

  Future<void> logout() async {
    state = const AsyncValue.loading();

    final authRepository = ref.watch(authRepositoryProvider);
    try {
      await authRepository.logout();
      state = const AsyncValue.data(null);
    } on Exception catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  //  Future<void> signInWithGoogle() async {
  //    state = const AsyncValue.loading();
  //
  //    try {
  //      final authRepository = ref.watch(authRepositoryProvider);
  //      await authRepository.signInWithGoogle();
  //      state = const AsyncValue.data(null);
  //    } catch (e, st) {
  //      state = AsyncValue.error(e, st);
  //      rethrow;
  //    }
  //  }
}
