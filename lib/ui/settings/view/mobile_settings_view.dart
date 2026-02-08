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
          final settings = state.settings;
          final displayName =
              profileState.profile?.displayName ??
              FirebaseAuth.instance.currentUser?.displayName;
          final phoneNumber = FirebaseAuth.instance.currentUser?.phoneNumber;
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
                    titleStyle: const TextStyle(fontSize: 12),
                    subtitleStyle: const TextStyle(fontSize: 11),
                    iconSize: 18,
                  ),
                  SettingsTile(
                    icon: Icons.phone_outlined,
                    title: 'Contact Number',
                    subtitle: phoneNumber ?? 'Not set',
                    titleStyle: const TextStyle(fontSize: 12),
                    subtitleStyle: const TextStyle(fontSize: 11),
                    iconSize: 18,
                  ),
                  SettingsTile(
                    icon: Icons.lock,
                    title: 'Change Password',
                    onTap: () {
                      ChangePasswordDialog.show(context);
                    },
                  ),
                  SettingsSwitchTile(
                    icon: Icons.email,
                    title: 'Email Updates',
                    subtitle: 'Receive updates and newsletters',
                    value: settings.account.emailUpdates,
                    onChanged: (value) {
                      ref
                          .read(settingsProvider.notifier)
                          .toggleEmailUpdates(value);
                    },
                  ),
                ],
              ),

            // Notifications Section
            SettingsSection(
              title: 'NOTIFICATIONS',
              children: [
                SettingsSwitchTile(
                  icon: Icons.notifications,
                  title: 'Push Notifications',
                  subtitle: 'Receive app notifications',
                  value: settings.notifications.pushEnabled,
                  onChanged: (value) {
                    ref
                        .read(settingsProvider.notifier)
                        .togglePushNotifications(value);
                  },
                ),
                SettingsSwitchTile(
                  icon: Icons.email_outlined,
                  title: 'Email Reports',
                  subtitle: 'Get weekly reports via email',
                  value: settings.notifications.emailReportsEnabled,
                  onChanged: (value) {
                    ref
                        .read(settingsProvider.notifier)
                        .toggleEmailReports(value);
                  },
                ),
                const Divider(height: 1),
                const Padding(
                  padding: EdgeInsets.all(12),
                  child: Text(
                    'ALERT PREFERENCES',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                ),
                SettingsSwitchTile(
                  icon: Icons.thermostat,
                  title: 'Temperature Alerts',
                  value: settings.notifications.temperatureAlertsEnabled,
                  onChanged: (value) {
                    ref
                        .read(settingsProvider.notifier)
                        .toggleTemperatureAlerts(value);
                  },
                ),
                SettingsSwitchTile(
                  icon: Icons.water_drop,
                  title: 'Moisture Alerts',
                  value: settings.notifications.moistureAlertsEnabled,
                  onChanged: (value) {
                    ref
                        .read(settingsProvider.notifier)
                        .toggleMoistureAlerts(value);
                  },
                ),
                SettingsSwitchTile(
                  icon: Icons.air,
                  title: 'Oxygen Alerts',
                  value: settings.notifications.oxygenAlertsEnabled,
                  onChanged: (value) {
                    ref
                        .read(settingsProvider.notifier)
                        .toggleOxygenAlerts(value);
                  },
                ),
              ],
            ),

            // Appearance Section Removed

            // Data & Privacy Section
            SettingsSection(
              title: 'DATA & PRIVACY',
              children: [
                SettingsTile(
                  icon: Icons.delete_forever,
                  title: 'Clear Cache',
                  onTap: () async {
                    final confirm = await showConfirmDialog(
                      context: context,
                      title: 'Clear Cache',
                      message: 'Are you sure you want to clear all cached data?',
                      confirmText: 'Clear',
                      cancelText: 'Cancel',
                    );
                    if (confirm == true) {
                      // TODO: Implement cache clearing
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Cache cleared')),
                        );
                      }
                    }
                  },
                ),
              ],
            ),

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

            const SizedBox(height: 10),
          ],
        );
      },
    ),   ); 
  }
}
