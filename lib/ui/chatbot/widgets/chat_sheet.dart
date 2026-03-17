import 'package:flutter/material.dart';
import 'package:flutter_application_1/ui/chatbot/widgets/chat_messages_list.dart';
import 'package:flutter_application_1/ui/chatbot/widgets/chat_prompt_input.dart';
import 'package:flutter_application_1/ui/chatbot/widgets/session_selector_sheet.dart';
import 'package:flutter_application_1/ui/core/themes/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatSheet extends ConsumerStatefulWidget {
  final String? sessionId;
  const ChatSheet({
    super.key,
    this.sessionId,
  });

  @override
  ConsumerState<ChatSheet> createState() => _ChatSheetState();
}

class _ChatSheetState extends ConsumerState<ChatSheet> {
  String? _activeSessionId;

  @override
  void initState() {
    super.initState();
    _activeSessionId = widget.sessionId;
  }

  @override
  void didUpdateWidget(covariant ChatSheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.sessionId != widget.sessionId) {
      _activeSessionId = widget.sessionId;
    }
  }

  void _handleSessionCreated(String sessionId) {
    setState(() {
      _activeSessionId = sessionId;
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.of(context).viewInsets;
    final activeSessionId = _activeSessionId;
    return AnimatedPadding(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(bottom: viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.background2,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.greenBackground,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.auto_awesome,
                        color: AppColors.green400,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'AI Assistant',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          Text(
                            activeSessionId == null
                                ? 'Start a new conversation'
                                : 'Session #$activeSessionId',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                          ),
                        ],
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: AppColors.background2,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(20),
                            ),
                          ),
                          builder: (context) => const SessionSelectorSheet(),
                        );
                      },
                      icon: const Icon(Icons.history, size: 18),
                      label: const Text('Sessions'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.green300,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Divider(height: 20),
              ),
              Expanded(
                child: activeSessionId == null
                    ? const _ChatEmptyState()
                    : ChatMessagesList(sessionId: activeSessionId),
              ),
              ChatPromptInput(
                sessionId: activeSessionId,
                onSessionCreated: _handleSessionCreated,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChatEmptyState extends StatelessWidget {
  const _ChatEmptyState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.blueBackground,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.chat_bubble_outline,
                color: AppColors.blueForeground,
                size: 28,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Ask anything about your process.',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              'Get quick answers, summaries, and next steps in seconds.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
