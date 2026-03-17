import 'package:flutter/material.dart';
import 'package:flutter_application_1/ui/chatbot/view_model/chatbot_sessions_notifier.dart';
import 'package:flutter_application_1/ui/chatbot/widgets/chat_sheet.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SessionSelectorSheet extends ConsumerWidget {
  const SessionSelectorSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionsAsync = ref.watch(chatbotSessionsProvider);
    return sessionsAsync.when(
      loading: () => CircularProgressIndicator(),
      error: (err, stack) => Center(child: Text('Error: $err')),
      data: (sessions) => Column(
        children: [
          ...sessions
              .where((s) => s.sessionId != null)
              .map(
                (session) => ListTile(
                  title: Text('Session ${session.sessionId}'),
                  onTap: () {
                    Navigator.of(context).pop();
                    showModalBottomSheet(
                      context: context,
                      builder: (_) => ChatSheet(sessionId: session.sessionId!),
                    );
                  },
                ),
              ),
          ElevatedButton(
            child: Text('Create New Session'),
            onPressed: () async {
              final notifier = ref.read(chatbotSessionsProvider.notifier);
              final newSessionId = await notifier.addNewSession();
              if (!context.mounted) return;
              if (newSessionId != null) {
                Navigator.of(context).pop();
                showModalBottomSheet(
                  context: context,
                  builder: (_) => ChatSheet(sessionId: newSessionId),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
