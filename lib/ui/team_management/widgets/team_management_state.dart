import 'package:freezed_annotation/freezed_annotation.dart';

part 'team_management_state.freezed.dart';

@freezed
abstract class TeamManagementState with _$TeamManagementState {
  const factory TeamManagementState({
    @Default(false) bool isLoading,
    @Default(null) String? errorMessage,
    @Default(null) String? successMessage,
  }) = _TeamManagementState;
}
