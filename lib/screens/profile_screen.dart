import 'package:flutter/material.dart';
import 'package:flutter_application_1/ui/auth/view/login_screen.dart';
import 'package:flutter_application_1/ui/auth/view_model/auth_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileScreen extends ConsumerWidget{
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text("Profile")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Profile Page", style: TextStyle(fontSize: 20)),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.logout),
              label: const Text("Logout"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () async {
                // ✅ Trigger sign-out
                await ref.read(authViewModelProvider.notifier).logout();

                // ✅ Navigate back to login screen
                if (context.mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RefactoredLoginScreen(),
                    ),
                    (route) => false, // remove all previous routes
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
