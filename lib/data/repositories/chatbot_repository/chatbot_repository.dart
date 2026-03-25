import 'package:flutter_application_1/data/models/chatbot_prompt.dart';

abstract class ChatbotPromptRepository {
  Future<void> addPrompt(String uid, String sessionId, ChatbotPrompt prompt);
  Stream<List<ChatbotPrompt>> streamMessages(String uid, String sessionId);
  Stream<ChatbotPrompt?> streamPrompt(
    String uid,
    String sessionId,
    String messageId,
  );
}
