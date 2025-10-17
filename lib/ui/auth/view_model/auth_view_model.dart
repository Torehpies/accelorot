import 'package:flutter_application_1/data/repositories/firebase_auth_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_view_model.g.dart';

@riverpod
class AuthViewModel extends _$AuthViewModel {
  @override
  FutureOr<void> build() => null;

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();

    final authRepository = ref.watch(authRepositoryProvider);
    try {
      await authRepository.login(email: email, password: password);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncError(e, st);
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

  Future<void> register(String email, String password, String fullName) async {
    state = const AsyncValue.loading();

    try {
      final authRepository = ref.watch(authRepositoryProvider);
      await authRepository.register(
        email: email,
        password: password,
        fullName: fullName,
      );
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
