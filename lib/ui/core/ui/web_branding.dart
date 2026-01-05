import 'package:flutter/material.dart';
import 'package:flutter_application_1/data/models/app_user.dart';
import 'package:flutter_application_1/data/providers/auth_providers.dart';
import 'package:flutter_application_1/ui/core/themes/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WebBranding extends ConsumerWidget {
  const WebBranding({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(appUserProvider);

    return userAsync.when(
      data: (AppUser? data) {
        final String? role = data?.teamRole ?? data?.globalRole;
        String? roleString = role == 'SuperAdmin' ? 'Super Admin' : role;
        final String firstName = data?.firstname ?? '';
        final String lastName = data?.lastname ?? '';
        final String name = '$firstName $lastName';
        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.green100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.energy_savings_leaf_rounded,
                size: 50,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Accel-O-Rot',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.green400,
                fontSize: 22,
              ),
            ),
            Text(
              '$roleString Portal',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.background2,
                borderRadius: BorderRadius.circular(8),
                // color: AppColors.textPrimary.withValues(alpha: .25),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 6,
                children: [
                  Icon(Icons.person_rounded, color: AppColors.green300),
                  Text(
                    name,
                    style: TextStyle(
                      letterSpacing: 1.0,
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
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
