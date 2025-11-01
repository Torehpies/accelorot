import 'package:flutter_application_1/repositories/auth_repository.dart';
import 'package:flutter_application_1/routes/router_notifier.dart';
import 'package:flutter_application_1/utils/google_auth_result.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'registration_notifier.g.dart';

// --- State Model ---
class RegistrationState {
  final String firstName;
  final String lastName;
  final String email;
  final String password;
  final String confirmPassword;

  final bool isLoading;
  final bool isGoogleLoading;
  final bool obscurePassword;
  final bool obscureConfirmPassword;
  final String? errorMessage;

  const RegistrationState({
    this.firstName = '',
    this.lastName = '',
    this.email = '',
    this.password = '',
    this.confirmPassword = '',
    this.isLoading = false,
    this.isGoogleLoading = false,
    this.obscurePassword = true,
    this.obscureConfirmPassword = true,
    this.errorMessage,
  });

  RegistrationState copyWith({
    String? firstName,
    String? lastName,
    String? email,
    String? password,
    String? confirmPassword,
    bool? isLoading,
    bool? isGoogleLoading,
    bool? obscurePassword,
    bool? obscureConfirmPassword,
    String? errorMessage,
  }) {
    return RegistrationState(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      isLoading: isLoading ?? this.isLoading,
      isGoogleLoading: isGoogleLoading ?? this.isGoogleLoading,
      obscurePassword: obscurePassword ?? this.obscurePassword,
      obscureConfirmPassword:
          obscureConfirmPassword ?? this.obscureConfirmPassword,
      errorMessage: errorMessage,
    );
  }
}

@riverpod
class RegistrationNotifier extends _$RegistrationNotifier {
  @override
  RegistrationState build() {
    return const RegistrationState();
  }

  // Update field states (used by controllers in the main screen)
  void updateFirstName(String value) =>
      state = state.copyWith(firstName: value);
  void updateLastName(String value) => state = state.copyWith(lastName: value);
  void updateEmail(String value) => state = state.copyWith(email: value);
  void updatePassword(String value) => state = state.copyWith(password: value);
  void updateConfirmPassword(String value) =>
      state = state.copyWith(confirmPassword: value);

  void togglePasswordVisibility() {
    state = state.copyWith(obscurePassword: !state.obscurePassword);
  }

  void toggleConfirmPasswordVisibility() {
    state = state.copyWith(
      obscureConfirmPassword: !state.obscureConfirmPassword,
    );
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  // --- Core Logic ---

  Future<void> registerUser() async {
    final authRepo = ref.read(authRepositoryProvider);
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final result = await authRepo.registerUser(
        email: state.email,
        password: state.password,
        firstName: state.firstName,
        lastName: state.lastName,
        role: 'Operator', // Force role
      );

      if (result['success']) {
        // Successful registration, no local error needed.
        // The router will handle navigation based on successful auth status.
        await ref.read(authListenableProvider.notifier).refreshUser();
      } else {
        state = state.copyWith(
          errorMessage: result['message'],
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'An unexpected error occurred.',
        isLoading: false,
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
