import 'package:flutter/material.dart';
import 'package:flutter_application_1/ui/chatbot/view_model/chatbot_prompt_input_provider.dart';
import 'package:flutter_application_1/ui/chatbot/view_model/chatbot_send_notifier.dart';
import 'package:flutter_application_1/ui/chatbot/view_model/chatbot_sessions_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatPromptInput extends ConsumerStatefulWidget {
  final String? sessionId;
  const ChatPromptInput({super.key, this.sessionId});

  @override
  ConsumerState<ChatPromptInput> createState() => _ChatPromptInputState();
}

class _ChatPromptInputState extends ConsumerState<ChatPromptInput> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final promptText = ref.watch(chatbotPromptInputProvider);
    final sendState = ref.watch(chatbotSendProvider);

    ref.listen<AsyncValue<void>>(chatbotSendProvider, (previous, next) {
      if (next.hasError) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(next.error.toString())));
      }

      if ((previous?.isLoading ?? false) && next.hasValue) {
        ref.read(chatbotPromptInputProvider.notifier).clear();
      }
    });

    ref.listen<String>(chatbotPromptInputProvider, (previous, next) {
      if (_controller.text != next) {
        _controller.value = TextEditingValue(
          text: next,
          selection: TextSelection.collapsed(offset: next.length),
        );
      }
    });

    final isSending = sendState.isLoading;
    final isDisabled = isSending || promptText.trim().isEmpty;

    Future<void> handleSend() async {
      if (isDisabled) return;
      final trimmed = promptText.trim();

      String? resolvedSessionId = widget.sessionId;
      if (resolvedSessionId == null) {
        final sessionNotifier = ref.read(chatbotSessionsProvider.notifier);
        resolvedSessionId = await sessionNotifier.addNewSession();
        if (resolvedSessionId == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to create session')),
          );
          return;
        }
      }

      await ref
          .read(chatbotSendProvider.notifier)
          .sendPrompt(sessionId: resolvedSessionId, prompt: trimmed);
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              enabled: !isSending,
              decoration: const InputDecoration(
                hintText: 'Type your question…',
              ),
              onChanged: (value) {
                ref.read(chatbotPromptInputProvider.notifier).setInput(value);
              },
              onSubmitted: (_) => handleSend(),
              textInputAction: TextInputAction.send,
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: isDisabled ? null : handleSend,
            child: isSending
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Send'),
          ),
        ],
      ),
    );
  }
}
