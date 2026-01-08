import 'package:flutter/material.dart';
import 'package:flutter_application_1/data/providers/auth_providers.dart';
import 'package:flutter_application_1/data/providers/team_providers.dart';
import 'package:flutter_application_1/data/services/api/model/team/team.dart';
import 'package:flutter_application_1/ui/registration/view_model/registration_state.dart';
import 'package:flutter_application_1/utils/ui_message.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'registration_notifier.g.dart';

@riverpod
class RegistrationNotifier extends _$RegistrationNotifier {
  @override
  RegistrationState build() {
    Future.microtask(() => loadTeams());
    return const RegistrationState();
  }

  void selectTeam(Team? team) {
    state = state.copyWith(selectedTeam: team);
    validateForm();
  }

  void updateEmail(String value) {
    final error = _validateEmail(value);
    state = state.copyWith(email: value, emailError: error);
    validateForm();
  }

  void updateFirstName(String value) {
    final error = _validateFirstName(value);
    state = state.copyWith(firstName: value, firstNameError: error);
    validateForm();
  }

  void updateLastName(String value) {
    final error = _validateLastName(value);
    state = state.copyWith(lastName: value, lastNameError: error);
    validateForm();
  }

  void updatePassword(String value) {
    final error = _validatePassword(value);
    state = state.copyWith(password: value, passwordError: error);
    validateForm();
  }

  void updateConfirmPassword(String value) {
    final error = _validateConfirmPassword(value);
    state = state.copyWith(confirmPassword: value, confirmPasswordError: error);
    validateForm();
  }

  void togglePasswordVisibility() {
    state = state.copyWith(obscurePassword: !state.obscurePassword);
  }

  void toggleConfirmPasswordVisibility() {
    state = state.copyWith(
      obscureConfirmPassword: !state.obscureConfirmPassword,
    );
  }

  Future<void> registerUser() async {
    validateForm();
    if (!state.isFormValid) {
      state = state.copyWith(
        message: UiMessage.error('Please fix your errors before registerting'),
      );
      return;
    }
    debugPrint("Starting registration");
    state = state.copyWith(isRegistrationLoading: true);

    final result = await ref
        .read(authRepositoryProvider)
        .signUp(
          email: state.email.trim(),
          password: state.password,
          firstName: state.firstName.trim(),
          lastName: state.lastName.trim(),
          globalRole: 'User',
          teamId: state.selectedTeam!.teamId!,
        );
    debugPrint('Email: ${state.email}');
    debugPrint('Password: ${state.password}');
    debugPrint('✅ Signup result: ${result.isSuccess ? "SUCCESS" : "FAILURE"}');
    debugPrint(
      'Error (if any): ${result.isFailure ? result.asFailure.userFriendlyMessage : "None"}',
    );

    state = state.copyWith(
      isRegistrationLoading: false,
      message: result.isSuccess
          ? UiMessage.success('Registration successful!')
          : UiMessage.error(result.asFailure.userFriendlyMessage),
    );
  }

  Future<void> signInWithGoogle() async {
    state = state.copyWith(isRegistrationLoading: true);

    final result = await ref.read(authRepositoryProvider).signInWithGoogle();
    state = state.copyWith(
      isRegistrationLoading: false,
      message: result.isSuccess
          ? UiMessage.success('Signed in with Google successfuly!')
          : UiMessage.error(result.asFailure.userFriendlyMessage),
    );
  }

  Future<void> loadTeams() async {
    state = state.copyWith(teams: const AsyncLoading());
    state = state.copyWith(
      teams: await AsyncValue.guard(
        () => ref.read(teamRepositoryProvider).getTeams(),
      ),
    );
  }

  void validateForm() {
    final valid =
        state.emailError == null &&
        state.firstNameError == null &&
        state.lastNameError == null &&
        state.passwordError == null &&
        state.confirmPasswordError == null &&
        state.selectedTeam != null;
    state = state.copyWith(isFormValid: valid);
  }

  String? _validateEmail(String v) {
    if (v.isEmpty) return 'Email is required';
    if (!_isValidEmail(v)) return 'Please enter a valid email';
    return null;
  }

  String? _validateFirstName(String v) {
    if (v.isEmpty) return 'First Name is required';
    if (v.length < 2) return 'At least 2 characters';
    if (!_isValidName(v)) return 'Invalid characters';
    return null;
  }

  String? _validateLastName(String v) {
    if (v.isEmpty) return 'Last Name is required';
    if (v.length < 2) return 'At least 2 characters';
    if (!_isValidName(v)) return 'Invalid characters';
    return null;
  }

  String? _validatePassword(String v) {
    if (v.isEmpty) return 'Password is required';
    if (v.length < 8) return 'Minimum 8 characters';
    return null;
  }

  String? _validateConfirmPassword(String v) {
    if (v.isEmpty) return 'Confirm Password is required';
    if (v != state.password) return 'Your password does not match';
    return null;
  }

  bool _isValidEmail(String email) {
    return RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
    ).hasMatch(email);
  }

  bool _isValidName(String name) {
    return RegExp(r"^[a-zA-ZÀ-ÿ\s'-]+$").hasMatch(name);
  }

  void clearMessage() {
    state = state.copyWith(message: null);
  }
}
