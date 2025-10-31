import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_1/repositories/auth_repository.dart';

class NavItem {
  final IconData icon;
  final String label;
  final String path;
  const NavItem(this.icon, this.label, this.path);
}

const List<NavItem> operatorNavItems = [
  NavItem(Icons.home, "Dashboard", "/dashboard"),
  NavItem(Icons.history, "Activity", "/activity"),
  NavItem(Icons.bar_chart, "Stats", "/stats"),
  NavItem(Icons.settings, "Machines", "/machines"),
  NavItem(Icons.person, "Profile", "/profile"),
];

const List<NavItem> adminNavItems = [
  NavItem(Icons.home, "Dashboard", "/admin/dashboard"),
  NavItem(Icons.history, "Operators", "/admin/operators"),
  NavItem(Icons.bar_chart, "Machines", "/admin/machines"),
  NavItem(Icons.person, "Profile", "/admin/profile"),
];

int getSelectedIndex(BuildContext context, List<NavItem> navItems) {
  final location = GoRouterState.of(context).matchedLocation;

  final index = navItems.indexWhere((item) => location.startsWith(item.path));
  return index < 0 ? 0 : index;
}

void goToPathByIndex(BuildContext context, int index, List<NavItem> navItems) {
  final path = navItems[index].path;
  context.go(path);
}

Future<void> handleLogout(
  BuildContext context, {
  required String roleName,
  required Color confirmColor,
}) async {
  final shouldLogout = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text('Confirm $roleName Logout'),
      content: Text(
        'Are you sure you want to log out of the $roleName Portal?',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(ctx, true),
          style: ElevatedButton.styleFrom(backgroundColor: confirmColor),
          child: const Text('Logout', style: TextStyle(color: Colors.white)),
        ),
      ],
    ),
  );

  if (shouldLogout == true && context.mounted) {
    // Read providers from the nearest ProviderScope without requiring a WidgetRef.
    final container = ProviderScope.containerOf(context, listen: false);
    try {
      await container.read(authRepositoryProvider).signOut();
    } catch (_) {
      // Fallback to direct Firebase sign out (e.g., if GoogleSignIn signOut throws on web)
      await FirebaseAuth.instance.signOut();
    }
  }
}

Widget buildOperatorWebBranding(BuildContext context) {
  return Column(
    children: [
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.eco, size: 40, color: Colors.white),
      ),
      const SizedBox(height: 12),
      const Text(
        'Accel-O-Rot',
        style: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 4),
      Text(
        'Operator Portal',
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.7),
          fontSize: 12,
        ),
      ),
      const SizedBox(height: 8),
      Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              child: const Icon(Icons.person, size: 16, color: Colors.white),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                FirebaseAuth.instance.currentUser?.email ?? 'User',
                style: const TextStyle(color: Colors.white, fontSize: 12),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

Widget buildAdminWebBranding(BuildContext context) {
  return Column(
    children: [
      const Icon(Icons.security, size: 50, color: Colors.white),
      const SizedBox(height: 8),
      const Text(
        'ADMIN CONSOLE',
        style: TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
      Text(
        FirebaseAuth.instance.currentUser?.email ?? 'Admin User',
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.8),
          fontSize: 14,
          fontStyle: FontStyle.italic,
        ),
        overflow: TextOverflow.ellipsis,
      ),
    ],
  );
}
