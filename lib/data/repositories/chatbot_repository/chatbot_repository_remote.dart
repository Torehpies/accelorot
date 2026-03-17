import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/data/models/chatbot_prompt.dart';
import 'package:flutter_application_1/data/repositories/chatbot_repository/chatbot_repository.dart';

class ChatbotPromptRepositoryRemote implements ChatbotPromptRepository {
  ChatbotPromptRepositoryRemote(this._firestore);
  final FirebaseFirestore _firestore;
  @override
  Future<void> addPrompt(
    String uid,
    String sessionId,
    ChatbotPrompt prompt,
  ) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('sessions')
        .doc(sessionId)
        .collection('messages')
        .add(prompt.toJson());
  }

  @override
  Stream<List<ChatbotPrompt>> streamMessages(String uid, String sessionId) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('sessions')
        .doc(sessionId)
        .collection('messages')
        .orderBy('createTime', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ChatbotPrompt.fromJson(doc.data()))
              .toList(),
        );
  }

  @override
  Stream<ChatbotPrompt?> streamPrompt(
    String uid,
    String sessionId,
    String messageId,
  ) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('sessions')
        .doc(sessionId)
        .collection('messages')
        .doc(messageId)
        .snapshots()
        .map((doc) => doc.exists ? ChatbotPrompt.fromJson(doc.data()!) : null);
  }
}
