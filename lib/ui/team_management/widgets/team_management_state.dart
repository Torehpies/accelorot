import 'package:flutter_application_1/data/services/api/model/team/team.dart';
import 'package:flutter_application_1/utils/ui_message.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'team_management_state.freezed.dart';

@freezed
abstract class TeamManagementState with _$TeamManagementState {
  const factory TeamManagementState({
    @Default(AsyncLoading()) AsyncValue<List<Team>> teams,
    @Default(false) bool isSavingTeams,
    UiMessage? message,
  }) = _TeamManagementState;
}
