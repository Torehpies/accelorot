import 'package:flutter/material.dart';
import 'package:flutter_application_1/routes/navigation_utils.dart';
import 'package:flutter_application_1/ui/chatbot/view_model/chatbot_sessions_notifier.dart';
import 'package:flutter_application_1/ui/chatbot/widgets/chat_sheet.dart';
import 'package:flutter_application_1/ui/chatbot/widgets/session_selector_sheet.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ResponsiveMobileShell extends StatelessWidget {
  final Widget child;
  final List<NavItem> navItems;
  final Color color;
  final Function(BuildContext, int) onTapped;
  final int? selectedIndex; // Optional: if set by StatefulShellRoute

  const ResponsiveMobileShell({
    super.key,
    required this.child,
    required this.navItems,
    required this.color,
    required this.onTapped,
    this.selectedIndex,
  });

  void _showSessionSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const SessionSelectorSheet(),
    );
  }

  Future<void> _showChatSheet(BuildContext context, WidgetRef ref) async {
    String? initialSessionId;
    try {
      final sessions = await ref.read(chatbotSessionsProvider.future);
      if (sessions.isNotEmpty) {
        final lastSession = sessions.first;
        final lastActive = lastSession.lastActive;
        if (lastActive != null &&
            DateTime.now().difference(lastActive) < const Duration(hours: 24)) {
          initialSessionId = lastSession.sessionId;
        }
      }
    } catch (_) {
      // Fallback to new session if fetch fails
    }

    if (!context.mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ChatSheet(sessionId: initialSessionId),
    );
  }

  @override
  Widget build(BuildContext context) {
    // final selectedIndex = getSelectedIndex(context, navItems);
    final String location = GoRouterState.of(context).uri.toString();
    final bool showFab = location != '/chat' &&
        location != '/operator/qr-scan' &&
        !location.endsWith('/settings');
    final index = selectedIndex ?? getSelectedIndex(context, navItems);

    return Scaffold(
      body: child,
      floatingActionButton: Visibility(
        visible: showFab,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 70.0),
          child: Consumer(
            builder: (context, ref, _) {
              return FloatingActionButton(
                onPressed: () => _showChatSheet(context, ref),
                elevation: 5,
                child: const Icon(Icons.smart_toy),
              );
            },
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: index,
        selectedItemColor: color,
        unselectedItemColor: Colors.grey,
        onTap: (i) => onTapped(context, i),
        items: navItems.map((item) {
          return BottomNavigationBarItem(
            icon: Icon(item.icon),
            label: item.label,
          );
        }).toList(),
      ),
    );
  }
}

