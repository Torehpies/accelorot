import 'package:flutter_application_1/data/models/chatbot_prompt.dart';
import 'package:flutter_application_1/data/providers/auth_providers.dart';
import 'package:flutter_application_1/data/providers/chatbot_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'chatbot_send_notifier.g.dart';

@riverpod
class ChatbotSendNotifier extends _$ChatbotSendNotifier {
  @override
  AsyncValue<void> build() {
    return const AsyncValue.data(null);
  }

  Future<void> sendPrompt({
    required String sessionId,
    required String prompt,
  }) async {
    final userId = ref.read(authUserProvider).value?.uid;
    if (userId == null) {
      state = AsyncValue.error('User not logged in', StackTrace.current);
      return;
    }

    if (sessionId.trim().isEmpty) {
      state = AsyncValue.error('Session not available', StackTrace.current);
      return;
    }

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(chatbotPromptRepositoryProvider);
      final payload = ChatbotPrompt(
        prompt: prompt,
      );
      await repo.addPrompt(userId, sessionId, payload);
    });
  }
}
