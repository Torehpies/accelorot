import 'package:flutter/material.dart';
import 'package:flutter_application_1/ui/chatbot/view_model/chatbot_prompt_input_provider.dart';
import 'package:flutter_application_1/ui/chatbot/view_model/chatbot_send_notifier.dart';
import 'package:flutter_application_1/ui/chatbot/view_model/chatbot_sessions_notifier.dart';
import 'package:flutter_application_1/ui/core/themes/app_theme.dart';
import 'package:flutter_application_1/ui/core/ui/app_snackbar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatPromptInput extends ConsumerStatefulWidget {
  final String? sessionId;
  final ValueChanged<String>? onSessionCreated;
  const ChatPromptInput({
    super.key,
    this.sessionId,
    this.onSessionCreated,
  });

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
        AppSnackbar.error(context, next.error.toString());
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
          AppSnackbar.error(context, 'Failed to create session');
          return;
        }
        widget.onSessionCreated?.call(resolvedSessionId);
      }

      await ref
          .read(chatbotSendProvider.notifier)
          .sendPrompt(sessionId: resolvedSessionId, prompt: trimmed);
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.background2,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.backgroundBorder),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 12,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                enabled: !isSending,
                minLines: 1,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Ask our AI assistant...',
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(horizontal: 6),
                ),
                onChanged: (value) {
                  ref.read(chatbotPromptInputProvider.notifier).setInput(value);
                },
                onSubmitted: (_) => handleSend(),
                textInputAction: TextInputAction.send,
              ),
            ),
            const SizedBox(width: 8),
            Material(
              color: isDisabled ? AppColors.grey : AppColors.green100,
              shape: const CircleBorder(),
              child: InkWell(
                onTap: isDisabled ? null : handleSend,
                customBorder: const CircleBorder(),
                child: SizedBox(
                  width: 44,
                  height: 44,
                  child: Center(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: isSending
                          ? const SizedBox(
                              key: ValueKey('loading'),
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Icon(
                              Icons.arrow_upward,
                              key: ValueKey('send'),
                              color: Colors.white,
                              size: 20,
                            ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
