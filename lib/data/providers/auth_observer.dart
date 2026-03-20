import 'package:flutter_application_1/data/providers/app_user_providers.dart';
import 'package:flutter_application_1/data/providers/auth_providers.dart';
import 'package:flutter_application_1/data/providers/core_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter/foundation.dart';

part 'auth_observer.g.dart';

@Riverpod(keepAlive: true)
void authObserver(Ref ref) {
  // Watch the basic firebase auth user
  final authUserAsync = ref.watch(authUserProvider);

  authUserAsync.whenData((user) async {
    if (user != null) {
      debugPrint('AuthObserver: User detected (\${user.uid}), checking FCM token...');
      
      try {
        final pushService = ref.read(pushNotificationServiceProvider);
        final userService = ref.read(appUserServiceProvider);
        
        final token = await pushService.getDeviceToken();
        if (token != null) {
          debugPrint('AuthObserver: Saving token to Firestore for \${user.uid}');
          await userService.updateUserField(user.uid, {'fcmToken': token});
        } else {
          debugPrint('AuthObserver: No FCM token retrieved (expected on Chrome without VAPID)');
        }
      } catch (e) {
        debugPrint('AuthObserver: Error updating FCM token: \$e');
      }
    } else {
      debugPrint('AuthObserver: No user logged in.');
    }
  });
}
