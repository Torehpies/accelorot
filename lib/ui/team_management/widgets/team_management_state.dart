import 'package:flutter_application_1/data/services/api/model/team/team.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'team_management_state.freezed.dart';

@freezed
abstract class TeamManagementState with _$TeamManagementState {
  const factory TeamManagementState({
		@Default([]) List<Team> teams,
    @Default(false) bool isLoadingTeams,
    @Default(false) bool isSavingTeams,
    String? errorMessage,
    String? successMessage,
  }) = _TeamManagementState;
}
