import 'package:flutter/material.dart';
import 'package:flutter_application_1/ui/chatbot/view_model/chatbot_messages_notifier.dart';
import 'package:flutter_application_1/ui/chatbot/widgets/chat_bubble.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatMessagesList extends ConsumerWidget {
  final String sessionId;
  const ChatMessagesList({super.key, required this.sessionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messages = ref.watch(chatbotMessagesProvider(sessionId));

    return messages.when(
      data: (items) {
        if (items.isEmpty) {
          return const SizedBox.shrink();
        }

        return ListView.builder(
          reverse: true,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final prompt = items[index];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ChatBubble(message: prompt.prompt, isUser: true),
                if ((prompt.response ?? '').isNotEmpty)
                  ChatBubble(message: prompt.response ?? '', isUser: false),
              ],
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text(error.toString())),
    );
  }
}
