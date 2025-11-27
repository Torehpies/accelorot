import 'package:freezed_annotation/freezed_annotation.dart';

part 'registration_state.freezed.dart';

@freezed
abstract class RegistrationState with _$RegistrationState {
  const factory RegistrationState({
    @Default(null) String? selectedTeamId,
    @Default(false) bool isRegistrationLoading,
    @Default(false) bool isGoogleLoading,
    @Default(true) bool obscurePassword,
    @Default(true) bool obscureConfirmPassword,
    @Default(null) String? errorMessage,
    @Default(null) String? successMessage,
  }) = _RegistrationState;
}
