import 'package:flutter_application_1/data/providers/auth_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'password_reset_notifier.g.dart';

@riverpod
class PasswordResetNotifier extends _$PasswordResetNotifier {
  @override
  AsyncValue<String?> build() => const AsyncValue.data(null);

  Future<void> sendResetEmail(String email) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final result = await ref.read(authRepositoryProvider).sendPasswordResetEmail(email);
      if (!result['success']) throw Exception(result['message']);
      return result['message'];
    });
  }
}
