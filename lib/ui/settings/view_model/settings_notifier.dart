import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/settings_model.dart';
import 'settings_state.dart';

part 'settings_notifier.g.dart';

@riverpod
class SettingsNotifier extends _$SettingsNotifier {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String? get _userId => _auth.currentUser?.uid;

  @override
  SettingsState build() {
    loadSettings();
    return const SettingsState.initial();
  }

  SettingsModel? get _loadedSettings =>
      state.maybeWhen(loaded: (settings) => settings, orElse: () => null);

  Future<void> loadSettings() async {
    if (_userId == null) {
      state = const SettingsState.error('User not authenticated');
      return;
    }

    state = const SettingsState.loading();

    try {
      final doc = await _firestore
          .collection('user_settings')
          .doc(_userId)
          .get();

      if (doc.exists) {
        final settings = SettingsModel.fromMap(doc.data()!);
        state = SettingsState.loaded(settings);
      } else {
        // Create default settings
        final defaultSettings = SettingsModel.initial();
        await _firestore
            .collection('user_settings')
            .doc(_userId)
            .set(defaultSettings.toMap());
        state = SettingsState.loaded(defaultSettings);
      }
    } catch (e) {
      state = SettingsState.error(e.toString());
    }
  }

  Future<void> updateAccountSettings(AccountSettings account) async {
    final currentSettings = _loadedSettings;
    if (_userId == null || currentSettings == null) return;

    final updated = currentSettings.copyWith(account: account);

    try {
      await _firestore.collection('user_settings').doc(_userId).update({
        'account': account.toMap(),
      });
      state = SettingsState.loaded(updated);
    } catch (e) {
      state = SettingsState.error(e.toString());
    }
  }

  Future<void> updateNotificationSettings(
    NotificationSettings notifications,
  ) async {
    final currentSettings = _loadedSettings;
    if (_userId == null || currentSettings == null) return;

    final updated = currentSettings.copyWith(notifications: notifications);

    try {
      await _firestore.collection('user_settings').doc(_userId).update({
        'notifications': notifications.toMap(),
      });
      state = SettingsState.loaded(updated);
    } catch (e) {
      state = SettingsState.error(e.toString());
    }
  }

  Future<void> togglePushNotifications(bool enabled) async {
    final currentSettings = _loadedSettings;
    if (currentSettings == null) return;

    final updated = currentSettings.notifications.copyWith(
      pushEnabled: enabled,
    );
    await updateNotificationSettings(updated);
  }

  Future<void> toggleEmailReports(bool enabled) async {
    final currentSettings = _loadedSettings;
    if (currentSettings == null) return;

    final updated = currentSettings.notifications.copyWith(
      emailReportsEnabled: enabled,
    );
    await updateNotificationSettings(updated);
  }

  Future<void> toggleTemperatureAlerts(bool enabled) async {
    final currentSettings = _loadedSettings;
    if (currentSettings == null) return;

    final updated = currentSettings.notifications.copyWith(
      temperatureAlertsEnabled: enabled,
    );
    await updateNotificationSettings(updated);
  }

  Future<void> toggleMoistureAlerts(bool enabled) async {
    final currentSettings = _loadedSettings;
    if (currentSettings == null) return;

    final updated = currentSettings.notifications.copyWith(
      moistureAlertsEnabled: enabled,
    );
    await updateNotificationSettings(updated);
  }

  Future<void> toggleOxygenAlerts(bool enabled) async {
    final currentSettings = _loadedSettings;
    if (currentSettings == null) return;

    final updated = currentSettings.notifications.copyWith(
      oxygenAlertsEnabled: enabled,
    );
    await updateNotificationSettings(updated);
  }

  Future<void> toggleEmailUpdates(bool enabled) async {
    final currentSettings = _loadedSettings;
    if (currentSettings == null) return;

    final updated = currentSettings.account.copyWith(emailUpdates: enabled);
    await updateAccountSettings(updated);
  }

  Future<void> toggleTwoFactor(bool enabled) async {
    final currentSettings = _loadedSettings;
    if (currentSettings == null) return;

    final updated = currentSettings.account.copyWith(twoFactorEnabled: enabled);
    await updateAccountSettings(updated);
  }
}
