import 'package:flutter/material.dart';
import 'package:flutter_application_1/routes/navigation_utils.dart';
import 'package:flutter_application_1/ui/chatbot/widgets/chat_sheet.dart';
import 'package:flutter_application_1/ui/chatbot/widgets/session_selector_sheet.dart';
import 'package:go_router/go_router.dart';

class ResponsiveMobileShell extends StatelessWidget {
  final Widget child;
  final List<NavItem> navItems;
  final Color color;
  final Function(BuildContext, int) onTapped;

  const ResponsiveMobileShell({
    super.key,
    required this.child,
    required this.navItems,
    required this.color,
    required this.onTapped,
  });

  void _showSessionSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const SessionSelectorSheet(),
    );
  }

  void _showChatSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: false,
      backgroundColor: Colors.transparent,
      builder: (context) => const ChatSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = getSelectedIndex(context, navItems);
    final String location = GoRouterState.of(context).uri.toString();
    final bool showFab = location != '/chat' && location != '/operator/qr-scan';

    return Scaffold(
      body: child,
      floatingActionButton: Visibility(
        visible: showFab,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 70.0),
          child: FloatingActionButton(
            onPressed: () => _showChatSheet(context),
            elevation: 5,
            child: const Icon(Icons.smart_toy),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: selectedIndex,
        selectedItemColor: color,
        unselectedItemColor: Colors.grey,
        onTap: (index) => onTapped(context, index),
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
