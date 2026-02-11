import 'package:flutter_application_1/utils/ui_message.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'approval_state.freezed.dart';

@freezed
abstract class ApprovalState with _$ApprovalState {
  const factory ApprovalState({
    @Default(false) bool isAccepting,
    UiMessage? message,
  }) = _ApprovalState;
}
