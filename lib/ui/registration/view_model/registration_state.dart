import 'package:flutter_application_1/data/services/api/model/team/team.dart';
import 'package:flutter_application_1/utils/ui_message.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'registration_state.freezed.dart';

@freezed
abstract class RegistrationState with _$RegistrationState {
  const factory RegistrationState({
    @Default(AsyncLoading()) AsyncValue<List<Team>> teams,
    Team? selectedTeam,
    @Default('') String email,
    String? emailError,
    @Default('') String firstName,
    String? firstNameError,
    @Default('') String lastName,
    String? lastNameError,
    @Default('') String password,
    String? passwordError,
    @Default('') String confirmPassword,
    String? confirmPasswordError,
    @Default(false) bool isRegistrationLoading,
    @Default(false) bool isGoogleLoading,
    @Default(false) bool isFormValid,
    @Default(true) bool obscurePassword,
    @Default(true) bool obscureConfirmPassword,
    UiMessage? message,
  }) = _RegistrationState;
}
