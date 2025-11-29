import 'package:flutter/material.dart';
import 'package:flutter_application_1/data/models/user.dart';
import 'package:flutter_application_1/data/providers/auth_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WebBranding extends ConsumerWidget {
  const WebBranding({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProfileProvider);

    return userAsync.when(
      data: (User? data) {
        final String? role = data?.globalRole ?? data?.teamRole;
        String? roleString = role == 'SuperAdmin' ? 'Super Admin' : role;
        final String firstName = data?.firstname ?? '';
        final String lastName = data?.lastname ?? '';
        final String name = '$firstName $lastName';
        return Column(
          children: [
            const Icon(Icons.security, size: 50, color: Colors.white),
            const SizedBox(height: 8),
            Text(
              '$roleString Portal',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.white.withValues(alpha: .25),
              ),
              child: Text(
                name,
                style: TextStyle(letterSpacing: 1.0 ,color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        );
      },
      error: (Object error, StackTrace stackTrace) {
        return Text('Error with user data');
      },
      loading: () {
        return CircularProgressIndicator();
      },
    );
  }
}
