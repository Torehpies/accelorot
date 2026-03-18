import 'package:flutter/material.dart';
import 'package:flutter_application_1/ui/chatbot/view_model/chatbot_sessions_notifier.dart';
import 'package:flutter_application_1/ui/core/themes/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SessionSelectorSheet extends ConsumerWidget {
  const SessionSelectorSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionsAsync = ref.watch(chatbotSessionsProvider);
    return sessionsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
      data: (sessions) {
        final items = sessions.where((s) => s.sessionId != null).toList();
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Conversations',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 12),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final session = items[index];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          radius: 18,
                          backgroundColor: AppColors.greenBackground,
                          child: const Icon(
                            Icons.chat_bubble_outline,
                            color: AppColors.green400,
                            size: 18,
                          ),
                        ),
                        title: Text('Session ${session.sessionId}'),
                        subtitle: const Text('Tap to resume'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          // Return the selected sessionId and close the sheet
                          Navigator.of(context).pop(session.sessionId);
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () async {
                    final notifier =
                        ref.read(chatbotSessionsProvider.notifier);
                    final newSessionId = await notifier.addNewSession();
                    if (!context.mounted) return;
                    if (newSessionId != null) {
                      // Return the new sessionId and close the sheet
                      Navigator.of(context).pop(newSessionId);
                    }
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('New session'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

