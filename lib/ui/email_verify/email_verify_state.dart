import 'package:flutter_application_1/utils/ui_message.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'email_verify_state.freezed.dart';

@freezed
abstract class EmailVerifyState with _$EmailVerifyState{
  const factory EmailVerifyState({
    @Default(false) bool isVerified,
    @Default(false) bool isResending,
    @Default(0) int resendCooldown,
    @Default(3) int dashboardCountdown,
		UiMessage? message,
  }) = _EmailVerifyState;


}
