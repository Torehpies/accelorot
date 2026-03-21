// lib/services/push_notification_service.dart

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

/// Top-level function for handling background messages.
/// This must be a top-level function (not inside a class) to run properly.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // We can't access Riverpod providers here, but we can log or do 
  // background processing (like updating a local database).
  debugPrint("Handling a background message: \${message.messageId}");
}

class PushNotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initialize() async {
    // 1. Request permission (especially for iOS, mostly automatic on Android)
    final settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    debugPrint('User granted permission: ${settings.authorizationStatus}');

    // 2. Register background handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // 3. Listen for foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Got a message whilst in the foreground!');
      debugPrint('Message data: \${message.data}');

      if (message.notification != null) {
        debugPrint('Message also contained a notification: \${message.notification}');
        // TODO: Optionally show a local in-app alert dialog or flushbar popup here
      }
    });
  }

  /// Retrieves the unique FCM token for this device.
  /// Used by the backend to send messages to this specific phone.
  Future<String?> getDeviceToken() async {
    try {
      String? token = await _firebaseMessaging.getToken();
      debugPrint("FCM Token: \$token");
      return token;
    } catch (e) {
      debugPrint("Failed to get FCM token: \$e");
      return null;
    }
  }

  /// Optional: Listen for token refreshes
  Stream<String> get onTokenRefresh => _firebaseMessaging.onTokenRefresh;
}
