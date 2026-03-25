import 'package:flutter_application_1/data/providers/app_user_providers.dart';
import 'package:flutter_application_1/data/providers/auth_providers.dart';
import 'package:flutter_application_1/data/providers/core_providers.dart';
import 'package:flutter_application_1/ui/activity_logs/view_model/unified_activity_viewmodel.dart';
import 'package:flutter_application_1/ui/machine_management/view_model/admin_machine_notifier.dart';
import 'package:flutter_application_1/ui/machine_management/view_model/machine_viewmodel.dart';
import 'package:flutter_application_1/ui/machine_management/view_model/operator_machine_notifier.dart';
import 'package:flutter_application_1/ui/operator_dashboard/view_model/operator_dashboard_viewmodel.dart';
import 'package:flutter_application_1/ui/operator_management/view_model/pending_members_notifier.dart';
import 'package:flutter_application_1/ui/operator_management/view_model/team_members_notifier.dart';
import 'package:flutter_application_1/ui/reports/view_model/mobile_reports_viewmodel.dart';
import 'package:flutter_application_1/ui/reports/view_model/reports_notifier.dart';
import 'package:flutter_application_1/ui/reports/view_model/reports_viewmodel.dart';
import 'package:flutter_application_1/data/providers/activity_providers.dart';
import 'package:flutter_application_1/data/providers/team_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter/foundation.dart';

part 'auth_observer.g.dart';

@Riverpod(keepAlive: true)
void authObserver(Ref ref) {
  // Detect user account switches and invalidate all keepAlive data providers
  // so the new user never sees stale data from the previous session.
  ref.listen(authUserProvider, (previous, next) {
    final prevUid = previous?.value?.uid;
    final nextUid = next.value?.uid;

    if (prevUid != nextUid) {
      debugPrint('AuthObserver: User changed ($prevUid → $nextUid). Clearing all keepAlive caches...');

      // Invalidate all keepAlive UI providers so they rebuild fresh for the new user
      ref.invalidate(unifiedActivityViewModelProvider);
      ref.invalidate(machineViewModelProvider);
      ref.invalidate(machineAggregatorServiceProvider);
      ref.invalidate(adminMachineProvider);
      ref.invalidate(operatorMachineProvider);
      ref.invalidate(operatorDashboardViewModelProvider);
      ref.invalidate(teamMembersProvider);
      ref.invalidate(pendingMembersProvider);
      ref.invalidate(currentTeamProvider);
      ref.invalidate(reportsProvider);
      ref.invalidate(reportsViewModelProvider);
      ref.invalidate(mobileReportsViewModelProvider);
      ref.invalidate(mobileReportsAggregatorServiceProvider);

      // Also clear the activity aggregator's in-memory cache
      ref.read(activityAggregatorProvider).clearCache();

      debugPrint('AuthObserver: All caches cleared.');
    }
  });

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
