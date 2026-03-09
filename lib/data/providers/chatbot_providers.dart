import 'package:flutter_application_1/data/providers/core_providers.dart';
import 'package:flutter_application_1/data/repositories/chatbot_repository/chatbot_repository.dart';
import 'package:flutter_application_1/data/repositories/chatbot_repository/chatbot_repository_remote.dart';
import 'package:flutter_application_1/data/repositories/chatbot_session_repository/chatbot_session_repository.dart';
import 'package:flutter_application_1/data/repositories/chatbot_session_repository/chatbot_session_repository_remote.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'chatbot_providers.g.dart';

@riverpod
ChatbotSessionRepository chatbotSessionRepository(Ref ref) {
  return ChatbotSessionRepositoryRemote(ref.read(firebaseFirestoreProvider));
}

@riverpod
ChatbotPromptRepository chatbotPromptRepository(Ref ref) {
  return ChatbotPromptRepositoryRemote(ref.read(firebaseFirestoreProvider));
}
