import 'package:flutter_application_1/data/models/profile_model.dart';
import 'package:flutter_application_1/data/models/prompt_status.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'chatbot_prompt.freezed.dart';
part 'chatbot_prompt.g.dart';

@freezed
abstract class ChatbotPrompt with _$ChatbotPrompt {
  const factory ChatbotPrompt({
    required String prompt,
    String? response,
    @TimestampConverter() DateTime? createTime,
    PromptStatus? status,
  }) = _ChatbotPrompt;

  factory ChatbotPrompt.fromJson(Map<String, dynamic> json) =>
      _$ChatbotPromptFromJson(json);
}
