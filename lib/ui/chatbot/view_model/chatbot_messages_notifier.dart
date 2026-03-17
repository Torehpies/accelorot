import 'dart:async';

import 'package:flutter_application_1/data/models/chatbot_prompt.dart';
import 'package:flutter_application_1/data/providers/auth_providers.dart';
import 'package:flutter_application_1/data/providers/chatbot_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'chatbot_messages_notifier.g.dart';

@riverpod
class ChatbotMessagesNotifier extends _$ChatbotMessagesNotifier {
  @override
  Stream<List<ChatbotPrompt>> build(String sessionId) {
    final userId = ref.watch(authUserProvider).value?.uid;
    if (userId == null) {
      return Stream.error('User not logged in');
    }
    final repo = ref.read(chatbotPromptRepositoryProvider);
    return repo.streamMessages(userId, sessionId);
  }
}

@riverpod
class ChatbotCurrentMessageNotifier extends _$ChatbotCurrentMessageNotifier {
  @override
  Stream<ChatbotPrompt?> build(String sessionId, String messageId) {
    final userId = ref.watch(authUserProvider).value?.uid;
    if (userId == null) {
      return Stream.error('User not logged in');
    }
    final repo = ref.read(chatbotPromptRepositoryProvider);
    return repo.streamPrompt(userId, sessionId, messageId);
  }
}
