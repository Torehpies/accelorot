import 'package:flutter/material.dart';
import 'package:flutter_application_1/ui/chatbot/widgets/chat_messages_list.dart';
import 'package:flutter_application_1/ui/chatbot/widgets/chat_prompt_input.dart';
import 'package:flutter_application_1/ui/chatbot/widgets/session_selector_sheet.dart';
import 'package:flutter_application_1/ui/core/themes/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatSheet extends ConsumerWidget {
  final String? sessionId;
  const ChatSheet({super.key, this.sessionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.white,
                      builder: (context) => const SessionSelectorSheet(),
                    );
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.green100,
                  ),
                  child: const Text('Open Sessions'),
                ),
              ),
            ),
            Expanded(
              child: sessionId == null
                  ? const Center(child: Text('Ask our AI chatbot 👋'))
                  : ChatMessagesList(sessionId: sessionId!),
            ),
            ChatPromptInput(sessionId: sessionId),
          ],
        ),
      ),
    );
  }
}
