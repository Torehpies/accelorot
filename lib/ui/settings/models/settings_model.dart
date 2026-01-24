
import 'package:equatable/equatable.dart';

class SettingsModel extends Equatable {
  final AccountSettings account;
  final NotificationSettings notifications;

  const SettingsModel({
    required this.account,
    required this.notifications,
  });

  factory SettingsModel.initial() {
    return const SettingsModel(
      account: AccountSettings.initial(),
      notifications: NotificationSettings.initial(),
    );
  }

  factory SettingsModel.fromMap(Map<String, dynamic> map) {
    return SettingsModel(
      account: AccountSettings.fromMap(map['account'] ?? {}),
      notifications: NotificationSettings.fromMap(map['notifications'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'account': account.toMap(),
      'notifications': notifications.toMap(),
    };
  }
  
  SettingsModel copyWith({
    AccountSettings? account,
    NotificationSettings? notifications,
  }) {
    return SettingsModel(
      account: account ?? this.account,
      notifications: notifications ?? this.notifications,
    );
  }

  @override
  List<Object?> get props => [account, notifications];
}

class AccountSettings extends Equatable {
  final bool twoFactorEnabled;
  final bool emailUpdates; // "Email Preferences"

  const AccountSettings({
    required this.twoFactorEnabled,
    required this.emailUpdates,
  });

  const AccountSettings.initial()
      : twoFactorEnabled = false,
        emailUpdates = true;

  factory AccountSettings.fromMap(Map<String, dynamic> map) {
    return AccountSettings(
      twoFactorEnabled: map['twoFactorEnabled'] ?? false,
      emailUpdates: map['emailUpdates'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'twoFactorEnabled': twoFactorEnabled,
      'emailUpdates': emailUpdates,
    };
  }

  AccountSettings copyWith({
    bool? twoFactorEnabled,
    bool? emailUpdates,
  }) {
    return AccountSettings(
      twoFactorEnabled: twoFactorEnabled ?? this.twoFactorEnabled,
      emailUpdates: emailUpdates ?? this.emailUpdates,
    );
  }

  @override
  List<Object?> get props => [twoFactorEnabled, emailUpdates];
}

class NotificationSettings extends Equatable {
  final bool pushEnabled;
  final bool emailReportsEnabled;
  final double tempThreshold;
  final double moistureThreshold;
  final double oxygenThreshold;
  final bool filterErrors;
  final bool filterWarnings;
  final bool temperatureAlertsEnabled;
  final bool moistureAlertsEnabled;
  final bool oxygenAlertsEnabled;

  const NotificationSettings({
    required this.pushEnabled,
    required this.emailReportsEnabled,
    required this.tempThreshold,
    required this.moistureThreshold,
    required this.oxygenThreshold,
    required this.filterErrors,
    required this.filterWarnings,
    required this.temperatureAlertsEnabled,
    required this.moistureAlertsEnabled,
    required this.oxygenAlertsEnabled,
  });

  const NotificationSettings.initial()
      : pushEnabled = true,
        emailReportsEnabled = true,
        tempThreshold = 70.0,
        moistureThreshold = 50.0,
        oxygenThreshold = 15.0,
        filterErrors = true,
        filterWarnings = true,
        temperatureAlertsEnabled = true,
        moistureAlertsEnabled = true,
        oxygenAlertsEnabled = true;

  factory NotificationSettings.fromMap(Map<String, dynamic> map) {
    return NotificationSettings(
      pushEnabled: map['pushEnabled'] ?? true,
      emailReportsEnabled: map['emailReportsEnabled'] ?? true,
      // Handle potential int to double conversion issues from Firestore
      tempThreshold: (map['tempThreshold'] as num?)?.toDouble() ?? 70.0,
      moistureThreshold: (map['moistureThreshold'] as num?)?.toDouble() ?? 50.0,
      oxygenThreshold: (map['oxygenThreshold'] as num?)?.toDouble() ?? 15.0,
      filterErrors: map['filterErrors'] ?? true,
      filterWarnings: map['filterWarnings'] ?? true,
      temperatureAlertsEnabled: map['temperatureAlertsEnabled'] ?? true,
      moistureAlertsEnabled: map['moistureAlertsEnabled'] ?? true,
      oxygenAlertsEnabled: map['oxygenAlertsEnabled'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'pushEnabled': pushEnabled,
      'emailReportsEnabled': emailReportsEnabled,
      'tempThreshold': tempThreshold,
      'moistureThreshold': moistureThreshold,
      'oxygenThreshold': oxygenThreshold,
      'filterErrors': filterErrors,
      'filterWarnings': filterWarnings,
      'temperatureAlertsEnabled': temperatureAlertsEnabled,
      'moistureAlertsEnabled': moistureAlertsEnabled,
      'oxygenAlertsEnabled': oxygenAlertsEnabled,
    };
  }

  NotificationSettings copyWith({
    bool? pushEnabled,
    bool? emailReportsEnabled,
    double? tempThreshold,
    double? moistureThreshold,
    double? oxygenThreshold,
    bool? filterErrors,
    bool? filterWarnings,
    bool? temperatureAlertsEnabled,
    bool? moistureAlertsEnabled,
    bool? oxygenAlertsEnabled,
  }) {
    return NotificationSettings(
      pushEnabled: pushEnabled ?? this.pushEnabled,
      emailReportsEnabled: emailReportsEnabled ?? this.emailReportsEnabled,
      tempThreshold: tempThreshold ?? this.tempThreshold,
      moistureThreshold: moistureThreshold ?? this.moistureThreshold,
      oxygenThreshold: oxygenThreshold ?? this.oxygenThreshold,
      filterErrors: filterErrors ?? this.filterErrors,
      filterWarnings: filterWarnings ?? this.filterWarnings,
      temperatureAlertsEnabled: temperatureAlertsEnabled ?? this.temperatureAlertsEnabled,
      moistureAlertsEnabled: moistureAlertsEnabled ?? this.moistureAlertsEnabled,
      oxygenAlertsEnabled: oxygenAlertsEnabled ?? this.oxygenAlertsEnabled,
    );
  }

  @override
  List<Object?> get props => [
        pushEnabled,
        emailReportsEnabled,
        tempThreshold,
        moistureThreshold,
        oxygenThreshold,
        filterErrors,
        filterWarnings,
        temperatureAlertsEnabled,
        moistureAlertsEnabled,
        oxygenAlertsEnabled,
      ];
}
