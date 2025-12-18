import 'package:flutter_application_1/data/services/api/model/team/team.dart';
import 'package:flutter_application_1/utils/ui_message.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'team_selection_state.freezed.dart';

@freezed
abstract class TeamSelectionState with _$TeamSelectionState {
  const factory TeamSelectionState({
    @Default(AsyncLoading()) AsyncValue<List<Team>> teams,
    Team? selectedTeam,
    @Default(false) bool isSubmitting,
    UiMessage? message,
  }) = _TeamSelectionState;
}
