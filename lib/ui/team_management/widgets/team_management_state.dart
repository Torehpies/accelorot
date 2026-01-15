import 'package:flutter_application_1/data/services/api/model/team/team.dart';
import 'package:flutter_application_1/utils/ui_message.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'team_management_state.freezed.dart';

@freezed
abstract class TeamManagementState with _$TeamManagementState {
  const factory TeamManagementState({
    @Default(<Team>[]) List<Team> teams,
    @Default({}) Map<int, List<Team>> pagesByIndex,
    @Default(0) int currentPage,
    @Default(10) int pageSize,
    @Default(false) bool isLoading,
    @Default(true) bool hasNextPage,
		DateTime? lastFetchedAt,
    @Default(false) bool isSavingTeams,
    UiMessage? message,
  }) = _TeamManagementState;
}
