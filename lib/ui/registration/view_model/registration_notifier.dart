import 'package:flutter_application_1/data/providers/auth_providers.dart';
import 'package:flutter_application_1/data/services/contracts/result.dart';
import 'package:flutter_application_1/ui/registration/view_model/registration_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'registration_notifier.g.dart';

@riverpod
class RegistrationNotifier extends _$RegistrationNotifier {
  @override
  RegistrationState build() {
    return const RegistrationState();
  }

  void updateSelectedTeamId(String? teamId) {
    state = state.copyWith(selectedTeamId: teamId);
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
    final authRepo = ref.read(authRepositoryProvider);
    state = state.copyWith(
      isRegistrationLoading: true,
      errorMessage: null,
      successMessage: null,
    );

    if (state.selectedTeamId == null) {
      state = state.copyWith(
        errorMessage: 'Please select a team.',
        isRegistrationLoading: false,
      );
      return;
    }

    final result = await authRepo.signUp(
      email: email,
      password: password,
      firstName: firstName,
      lastName: lastName,
      globalRole: 'User',
      teamId: state.selectedTeamId!,
    );

    if (!ref.mounted) {
      return;
    }

    result.when(
      success: (_) {
        state = state.copyWith(
          isRegistrationLoading: false,
          errorMessage: null,
          successMessage: 'Registration successful. Please check your email.',
        );
      },
      failure: (error) {
        final userMessage = (error).userFriendlyMessage;

        state = state.copyWith(
          isRegistrationLoading: false,
          errorMessage: userMessage,
          successMessage: null,
        );
      },
    );
  }

  Future<void> signInWithGoogle() async {
    final authRepo = ref.read(authRepositoryProvider);
    state = state.copyWith(
      isGoogleLoading: true,
      errorMessage: null,
      successMessage: null,
    );

    final result = await authRepo.signInWithGoogle();

    if (!ref.mounted) {
      return;
    }

    result.when(
      success: (_) {
        state = state.copyWith(
          isGoogleLoading: false,
          errorMessage: null,
					successMessage: 'Google sign-in successful',
        );
      },
      failure: (error) {
        final userMessage = (error).userFriendlyMessage;

        state = state.copyWith(
          isGoogleLoading: false,
          errorMessage: userMessage,
          successMessage: null,
        );
      },
    );
  }
}
