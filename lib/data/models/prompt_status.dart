import 'package:flutter_application_1/data/models/profile_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'prompt_status.freezed.dart';
part 'prompt_status.g.dart';

@freezed
abstract class PromptStatus with _$PromptStatus {
  const factory PromptStatus({
    String? state,
    @TimestampConverter() DateTime? completeTime,
    @TimestampConverter() DateTime? startTime,
    @TimestampConverter() DateTime? updateTime,
  }) = _PromptStatus;

  factory PromptStatus.fromJson(Map<String, dynamic> json) =>
      _$PromptStatusFromJson(json);
}
