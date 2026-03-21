import 'package:flutter_application_1/data/services/api/model/team/team.dart';
import 'package:flutter_application_1/utils/ui_message.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'complete_profile_state.freezed.dart';

@freezed
abstract class CompleteProfileState with _$CompleteProfileState {
  const factory CompleteProfileState({
    @Default('') String firstName,
    @Default('') String lastName,
    Team? selectedTeam,
    @Default(AsyncValue.loading()) AsyncValue<List<Team>> teams,
    @Default(false) bool isSubmitting,
    @Default(false) bool isFormValid,
    UiMessage? message,
    String? firstNameError,
    String? lastNameError,
  }) = _CompleteProfileState;
}
