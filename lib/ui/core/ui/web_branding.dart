import 'package:flutter/material.dart';
import 'package:flutter_application_1/data/models/app_user.dart';
import 'package:flutter_application_1/data/providers/auth_providers.dart';
import 'package:flutter_application_1/ui/core/themes/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';

class WebBranding extends ConsumerWidget {
  const WebBranding({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(appUserProvider);

    final isTablet =
        MediaQuery.of(context).size.width >= kTabletBreakpoint &&
        MediaQuery.of(context).size.width < kDesktopBreakpoint;

    final iconSize = 65.0;
    final smallIconSize = 40.0;

    return userAsync.when(
      data: (AppUser? data) {
        final String? role = data?.teamRole ?? data?.globalRole;
        String? roleString = role == 'SuperAdmin' ? 'Super Admin' : role;
        final String firstName = data?.firstname ?? '';
        final String lastName = data?.lastname ?? '';
        final String name = '$firstName $lastName';
        return Column(
          children: [
            SvgPicture.asset(
              'assets/images/Accelorot_logo.svg',
              width: isTablet ? smallIconSize : iconSize,
              height: isTablet ? smallIconSize : iconSize,
              fit: BoxFit.contain,
              semanticsLabel: 'Accelorot logo',
            ),
            const SizedBox(height: 8),
            if (!isTablet) ...[
              const Text(
                'ACCEL-O-ROT',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.background2,
                  borderRadius: BorderRadius.circular(8),
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
            ] else ...[
              // Tablet: initials avatar only
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Tooltip(
                  message: name.trim().isEmpty ? 'No name' : name.trim(),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.background2,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      _getInitials(firstName, lastName),
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
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

String _getInitials(String firstName, String lastName) {
  final firstInitial = firstName.isNotEmpty ? firstName[0].toUpperCase() : '';
  final lastInitial = lastName.isNotEmpty ? lastName[0].toUpperCase() : '';
  return '$firstInitial$lastInitial';
}
