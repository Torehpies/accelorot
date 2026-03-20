import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
//import 'package:go_router/go_router.dart';
//import 'package:flutter_application_1/routes/route_path.dart';
import '../view_model/settings_notifier.dart';
import '../view_model/settings_state.dart';
import '../widgets/settings_section.dart';     
import '../widgets/settings_tile.dart';
import '../../change_password_dialog/widgets/change_password_dialog.dart';
import '../../core/ui/confirm_dialog.dart';
import '../../profile_screen/view_model/profile_notifier.dart';
import '../../core/themes/app_theme.dart';
import '../../../routes/navigation_utils.dart';
import 'package:go_router/go_router.dart';

class MobileSettingsView extends ConsumerWidget {
  const MobileSettingsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: const SettingsContent(),
    );
  }
}

class SettingsContent extends ConsumerWidget {
  const SettingsContent({super.key});

  String _roleNameForContext(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith('/admin')) {
      return 'Admin';
    }
    if (location.startsWith('/superadmin')) {
      return 'Super Admin';
    }
    return 'Operator';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsState = ref.watch(settingsProvider);
    final profileState = ref.watch(profileProvider);

    return Scaffold(
      body: settingsState.map(
        initial: (_) => const Center(child: CircularProgressIndicator()),
        loading: (_) => const Center(child: CircularProgressIndicator()),
        error: (state) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: ${state.message}'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.read(settingsProvider.notifier).loadSettings();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        loaded: (state) {
          final displayName =
              profileState.profile?.displayName ??
              FirebaseAuth.instance.currentUser?.displayName;
          return ListView(
            children: [
              // Account Section
              SettingsSection(
                title: 'ACCOUNT',
                children: [
                  SettingsTile(
                    icon: Icons.person,
                    title: 'Profile Information',
                    subtitle: FirebaseAuth.instance.currentUser?.email,
                  ),
                  SettingsTile(
                    icon: Icons.badge_outlined,
                    title: 'Name',
                    subtitle: displayName ?? 'Not set',
                  ),
                  SettingsTile(
                    icon: Icons.lock,
                    title: 'Change Password',
                    onTap: () {
                      ChangePasswordDialog.show(context);
                    },
                  ),
                ],
              ),



            // Appearance Section Removed


            // About Section
            SettingsSection(
              title: 'ABOUT',
              children: [
                SettingsTile(
                  icon: Icons.info,
                  title: 'Version',
                  trailing: const Text(
                    '0.0.0',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                SettingsTile(
                  icon: Icons.privacy_tip,
                  title: 'Privacy Policy',
                  onTap: () {
                    // TODO: Show privacy policy
                  },
                ),
                SettingsTile(
                  icon: Icons.description,
                  title: 'Terms of Service',
                  onTap: () {
                    // TODO: Show terms
                  },
                ),
                SettingsTile(
                  icon: Icons.help,
                  title: 'Help & Support',
                  onTap: () {
                    // TODO: Show help
                  },
                ),
              ],
            ),
            SettingsSection(
              title: 'SESSION',
              children: [
                SettingsTile(
                  icon: Icons.logout,
                  title: 'Log Out',
                  iconColor: AppColors.textPrimary,
                  titleStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  hoverColor: AppColors.background,
                  splashColor: AppColors.background,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  onTap: () async {
                    await handleLogout(
                      context,
                      roleName: _roleNameForContext(context),
                      confirmColor: AppColors.error,
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 10),
          ],
        );
      },
    ),   ); 
  }
}
