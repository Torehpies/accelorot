import 'package:flutter_application_1/data/providers/auth_providers.dart';
import 'package:flutter_application_1/data/repositories/firebase_auth_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_view_model.g.dart';

@riverpod
class AuthViewModel extends _$AuthViewModel {
  late final FirebaseAuthRepository _repository = ref.read(
    firebaseAuthRepositoryProvider,
  );

  @override
  FutureOr<void> build() => null;

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();

    try {
      await _repository.login(email, password);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> logout() async {
    state = const AsyncValue.loading();

    final result = await AsyncValue.guard(() async {
      await _repository.logout();
    });

    state = result;
  }
}
