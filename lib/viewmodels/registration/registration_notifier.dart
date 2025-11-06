import 'package:flutter_application_1/repositories/auth_repository.dart';
import 'package:flutter_application_1/routes/router_notifier.dart';
import 'package:flutter_application_1/utils/google_auth_result.dart';
import 'package:flutter_application_1/viewmodels/registration/registration_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'registration_notifier.g.dart';

@riverpod
class RegistrationNotifier extends _$RegistrationNotifier {
  @override
  RegistrationState build() {
    return RegistrationState();
  }

  // Update field states (used by controllers in the main screen)
  //  void updateFirstName(String value) =>
  //      state = state.copyWith(firstName: value);
  //  void updateLastName(String value) => state = state.copyWith(lastName: value);
  //  void updateEmail(String value) => state = state.copyWith(email: value);
  //  void updatePassword(String value) => state = state.copyWith(password: value);
  //  void updateConfirmPassword(String value) =>
  //      state = state.copyWith(confirmPassword: value);
  void updateSelectedTeamId(String? teamId) {
    state = state.copyWith(selectedTeamId: () => teamId);
  }

  void togglePasswordVisibility() {
    state = state.copyWith(obscurePassword: !state.obscurePassword);
  }

  void toggleConfirmPasswordVisibility() {
    state = state.copyWith(
      obscureConfirmPassword: !state.obscureConfirmPassword,
    );
  }

  // --- Core Logic ---

  Future<void> registerUser({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    final routerNotifier = ref.read(authListenableProvider.notifier);
    state = state.copyWith(isRegistrationLoading: true, errorMessage: null);

    if (state.selectedTeamId == null) {
      state = state.copyWith(
        errorMessage: 'Please select a team.',
        isRegistrationLoading: false,
      );
      return;
    }

    try {
      await routerNotifier.registerAndSetState(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        role: 'Operator',
        teamId: state.selectedTeamId!,
      );

      state = state.copyWith(isRegistrationLoading: false);
    } catch (e) {
      state = state.copyWith(
        errorMessage: e.toString(),
        isRegistrationLoading: false,
      );
    }
  }

  Future<void> signInWithGoogle() async {
    final authRepo = ref.read(authRepositoryProvider);
    state = state.copyWith(isRegistrationLoading: true, errorMessage: null);

    try {
      final result = await authRepo.signInWithGoogle();

      if (result is GoogleLoginSuccess) {
        /// stop loading on google sign-in success
        state = state.copyWith(
          isRegistrationLoading: false,
          errorMessage: null,
        );
      } else if (result is GoogleLoginFailure) {
        /// stop loading on google sign-in failure
        state = state.copyWith(
          isRegistrationLoading: false,
          errorMessage: result.message,
        );
      }
    } on Exception {
      // Catch unexpected errors during the sign-in call itself
      state = state.copyWith(
        isRegistrationLoading: false,
        errorMessage: 'An unexpected error occurred during Google sign-in.',
      );
    }
  }
}
