import 'package:flutter_application_1/data/models/profile_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'chatbot_session.freezed.dart';
part 'chatbot_session.g.dart';

@freezed
abstract class ChatbotSession with _$ChatbotSession {
  const factory ChatbotSession({
		String? sessionId,
    @TimestampConverter() DateTime? createdAt,
    @TimestampConverter() DateTime? lastActive,
  }) = _ChatbotSession;

  factory ChatbotSession.fromJson(Map<String, dynamic> json) =>
      _$ChatbotSessionFromJson(json);
}
