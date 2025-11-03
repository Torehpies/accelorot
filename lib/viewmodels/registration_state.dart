import 'package:flutter/material.dart';
import 'package:flutter_application_1/repositories/team_repository.dart';

class RegistrationState {
  final String? selectedTeamId;
  final String firstName;
  final String lastName;
  final String email;
  final String password;
  final String confirmPassword;
  final bool isRegistrationLoading;
  final bool isGoogleLoading;
  final bool obscurePassword;
  final bool obscureConfirmPassword;
  final String? errorMessage;
  final String? successMessage;

  RegistrationState({
    this.selectedTeamId,
    this.firstName = '',
    this.lastName = '',
    this.email = '',
    this.password = '',
    this.confirmPassword = '',
    this.isRegistrationLoading = false,
    this.isGoogleLoading = false,
    this.obscurePassword = true,
    this.obscureConfirmPassword = true,
    this.errorMessage,
    this.successMessage,
  });

  RegistrationState copyWith({
    ValueGetter<String?>? selectedTeamId,
    String? firstName,
    String? lastName,
    String? email,
    String? password,
    String? confirmPassword,
    bool? isRegistrationLoading,
    bool? isGoogleLoading,
    bool? obscurePassword,
    bool? obscureConfirmPassword,
    String? errorMessage,
    String? successMessage,
  }) {
    return RegistrationState(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      selectedTeamId: selectedTeamId != null
          ? selectedTeamId()
          : this.selectedTeamId,
      isRegistrationLoading:
          isRegistrationLoading ?? this.isRegistrationLoading,
      isGoogleLoading: isGoogleLoading ?? this.isGoogleLoading,
      obscurePassword: obscurePassword ?? this.obscurePassword,
      obscureConfirmPassword:
          obscureConfirmPassword ?? this.obscureConfirmPassword,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }
}
