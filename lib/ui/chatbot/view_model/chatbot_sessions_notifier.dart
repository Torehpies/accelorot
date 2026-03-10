import 'package:flutter_application_1/data/models/chatbot_session.dart';
import 'package:flutter_application_1/data/providers/auth_providers.dart';
import 'package:flutter_application_1/data/providers/chatbot_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'chatbot_sessions_notifier.g.dart';

@riverpod
class ChatbotSessionsNotifier extends _$ChatbotSessionsNotifier {
  @override
  FutureOr<List<ChatbotSession>> build() async {
    final repo = ref.read(chatbotSessionRepositoryProvider);
    final userId = ref.watch(authUserProvider).value?.uid;
    if (userId == null) {
      throw Exception("User not logged in.");
    }
    final sessions = await repo.getSessions(userId);
    final sortedSessions = List<ChatbotSession>.from(sessions)
      ..sort(
        (a, b) => b.lastActive?.compareTo(a.lastActive ?? DateTime(0)) ?? 0,
      );
    return sortedSessions.take(3).toList();
  }

  Future<void> getSessions() async {
    final repo = ref.read(chatbotSessionRepositoryProvider);
    final userId = ref.watch(authUserProvider).value?.uid;
    if (userId == null) {
      state = AsyncValue.error("User not logged in", StackTrace.current);
      return;
    }
    state = AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final sessions = await repo.getSessions(userId);
      final sortedSessions = List<ChatbotSession>.from(sessions)
        ..sort(
          (a, b) => b.lastActive?.compareTo(a.lastActive ?? DateTime(0)) ?? 0,
        );
      return sortedSessions.take(3).toList();
    });
  }
}
