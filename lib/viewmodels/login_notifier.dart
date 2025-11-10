import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/utils/firebase_error.dart';
import 'package:flutter_application_1/providers/auth_providers.dart';

import '../utils/google_auth_result.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'login_notifier.g.dart';

class LoginState {
  final String email;
  final String password;
  final bool isLoading;
  final bool obscurePassword;
  final String? errorMessage;
  final bool isFormValid;

  const LoginState({
    this.email = '',
    this.password = '',
    this.isLoading = false,
    this.obscurePassword = true,
    this.errorMessage,
    this.isFormValid = false,
  });

  LoginState copyWith({
    String? email,
    String? password,
    bool? isLoading,
    bool? obscurePassword,
    String? errorMessage,
    bool? isFormValid,
  }) {
    return LoginState(
      email: email ?? this.email,
      password: password ?? this.password,
      isLoading: isLoading ?? this.isLoading,
      obscurePassword: obscurePassword ?? this.obscurePassword,
      errorMessage: errorMessage,
      isFormValid: isFormValid ?? this.isFormValid,
    );
  }
}

@riverpod
class LoginNotifier extends _$LoginNotifier {
  @override
  LoginState build() {
    return const LoginState();
  }

  void updateEmail(String email) =>
      state = state.copyWith(email: email, errorMessage: null);
  void updatePassword(String password) =>
      state = state.copyWith(password: password, errorMessage: null);
  void togglePasswordVisibility() =>
      state = state.copyWith(obscurePassword: !state.obscurePassword);
  void updateFormValidity(bool isValid) =>
      state = state.copyWith(isFormValid: isValid);

  void clearError() => state = state.copyWith(errorMessage: null);

  void handleForgotPassword() {
    // TODO
  }

  Future<void> signInWithEmail() async {
    final authRepo = ref.read(authRepositoryProvider);
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      await authRepo.signInWithEmail(state.email, state.password);
      // stop loading on success
      state = state.copyWith(isLoading: false, errorMessage: null);
    } on FirebaseAuthException catch (e) {
      /// stop loading on auth error
      state = state.copyWith(
        isLoading: false,
        errorMessage: mapAuthErrorCodeToMessage(e.code),
      );
    } catch (e) {
      /// stop loading on error
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'A connection error occurred. Please check your network.',
      );
    }
  }

  Future<void> signInWithGoogle() async {
    final authRepo = ref.read(authRepositoryProvider);
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final result = await authRepo.signInWithGoogle();

      if (result is GoogleLoginSuccess) {
        /// stop loading on google sign-in success
        state = state.copyWith(isLoading: false, errorMessage: null);
      } else if (result is GoogleLoginFailure) {
        /// stop loading on google sign-in failure
        state = state.copyWith(isLoading: false, errorMessage: result.message);
      }
    } on Exception {
      // Catch unexpected errors during the sign-in call itself
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'An unexpected error occurred during Google sign-in.',
      );
    }
  }

}
