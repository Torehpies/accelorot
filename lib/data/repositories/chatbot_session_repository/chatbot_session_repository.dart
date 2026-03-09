import 'package:flutter_application_1/data/models/chatbot_session.dart';

abstract class SessionRepository {
  Future<String> createSession(ChatbotSession session);
  Future<ChatbotSession?> getSession(String uid, String sessionId);
  Future<List<ChatbotSession>> getSessions(String uid);
  Stream<List<ChatbotSession>> streamSessions(String uid);
  Future<void> updateSession(String uid, ChatbotSession session);
  Future<void> deleteSession(String uid, String sessionId);
}
