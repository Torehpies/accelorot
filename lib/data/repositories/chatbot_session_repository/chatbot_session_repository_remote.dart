import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/data/models/chatbot_session.dart';
import 'package:flutter_application_1/data/repositories/chatbot_session_repository/chatbot_session_repository.dart';
import 'package:flutter_application_1/data/utils/collection_references.dart';

class ChatbotSessionRepositoryRemote implements ChatbotSessionRepository {
  ChatbotSessionRepositoryRemote(this._firestore);
  final FirebaseFirestore _firestore;
  @override
  Future<String> createSession(String uid, ChatbotSession session) async {
    try {
      final collection = sessionCollection(uid, _firestore);
      if (session.sessionId != null && session.sessionId!.isNotEmpty) {
        await collection.doc(session.sessionId).set(session.toJson());
        return session.sessionId!;
      } else {
        final docRef = await collection.add(session.toJson());
        await docRef.set(
          session.copyWith(sessionId: docRef.id).toJson(),
          SetOptions(merge: true),
        );
        return docRef.id;
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ChatbotSession?> getSession(String uid, String sessionId) async {
    try {
      final doc = await sessionCollection(uid, _firestore).doc(sessionId).get();
      if (!doc.exists) return null;
      final session = ChatbotSession.fromJson(doc.data()!);
      return session.copyWith(sessionId: doc.id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<ChatbotSession>> getSessions(String uid) async {
    try {
      final snapshot = await sessionCollection(
        uid,
        _firestore,
      ).orderBy('lastActive', descending: true).limit(5).get();
      return snapshot.docs
          .map(
            (doc) =>
                ChatbotSession.fromJson(doc.data()).copyWith(sessionId: doc.id),
          )
          .toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Stream<List<ChatbotSession>> streamSessions(String uid) {
    return sessionCollection(uid, _firestore).snapshots().map(
      (snapshot) => snapshot.docs
          .map(
            (doc) =>
                ChatbotSession.fromJson(doc.data()).copyWith(sessionId: doc.id),
          )
          .toList(),
    );
  }

  @override
  Future<void> updateSession(String uid, ChatbotSession session) async {
    if (session.sessionId == null || session.sessionId!.isEmpty) {
      throw Exception("Cannot update session: sessionId missing");
    }
    await sessionCollection(
      uid,
      _firestore,
    ).doc(session.sessionId).set(session.toJson());
  }

  @override
  Future<void> deleteSession(String uid, String sessionId) async {
    await sessionCollection(uid, _firestore).doc(sessionId).delete();
  }
}
